# dev→main 버전 사이클 + ghcr Docker 이미지

`feature/* → dev → main` 흐름으로 SemVer 버전을 git tag · GitHub Release · GitHub Packages(ghcr) 에
한 번에 기록하고, dev 에서 검증한 이미지를 **재빌드 없이 승격**해 프로덕션에 배포하는 CI 템플릿.

## 사이클

```
feature/* ──PR──▶ dev ──────────────▶ main
                  │                    │
   (push:dev)     │   (push:main = 승격)
   dev-ci.yml     │   release-promote.yml
   ├ build+push   │   ├ next-version.sh  (마지막 v* 태그 + commits → vX.Y.Z)
   │  :latest-dev │   ├ imagetools create  (latest-dev digest 그대로)
   │  :dev-<sha>  │   │     → :X.Y.Z  +  :latest-prd   (재빌드 X)
   └ memory append│   ├ git tag vX.Y.Z + push
     [skip ci]    │   └ GitHub Release
                  ▼
            ghcr.io/<owner>/<repo>
            latest-dev · dev-<sha> · X.Y.Z · latest-prd
```

- **`:latest-dev`** — dev 에 머지될 때마다 갱신 (개발 통합본)
- **`:dev-<sha>`** — 커밋별 immutable 추적 태그
- **`:X.Y.Z`** — 릴리스 버전 (= git tag = GitHub Release = ghcr 패키지 레코드)
- **`:latest-prd`** — 현재 프로덕션. `latest-dev → latest-prd` 승격이 곧 버전업 + 실서버 배포

> **핵심**: main 머지 시 이미지를 다시 빌드하지 않고 `latest-dev` 의 digest 를 그대로 re-tag 합니다.
> dev 에서 테스트한 바이트가 그대로 프로덕션에 올라갑니다.

## 버전 결정 (SemVer 자동)

`next-version.sh` 가 마지막 `v*` 태그 이후 conventional commits 로 다음 버전을 계산:

| 커밋 | bump |
|------|------|
| `<type>!:` 또는 본문 `BREAKING CHANGE` | **major** |
| `feat:` | **minor** |
| 그 외 (`fix:`/`chore:`/…) | **patch** |
| 태그 없음 (첫 릴리스) | `0.1.0` |

**강제 지정**: dev→main PR 의 머지(스쿼시) 메시지에 `release:major|minor|patch` 를 넣으면 자동 판정을 덮어씀.

## 설치

```bash
mkdir -p .github/workflows .github/scripts
cp .claude/templates/cicd/dev-ci.yml           .github/workflows/dev-ci.yml
cp .claude/templates/cicd/release-promote.yml  .github/workflows/release-promote.yml
cp .claude/templates/cicd/next-version.sh      .github/scripts/next-version.sh
chmod +x .github/scripts/next-version.sh
cp .claude/templates/cicd/Dockerfile.example   Dockerfile   # 자기 앱에 맞게 수정
```

`/init` Step 5 에서 "Docker 배포 사이클 설치?" 에 동의하면 위 복사가 자동 수행됩니다.

## 사전 설정 (필수)

1. **브랜치**: `dev` 와 `main` 존재 (`/init` 의 main+dev 전략). PR 흐름은 `feature/* → dev`, 릴리스는 `dev → main`.
2. **Workflow 권한**: repo → Settings → Actions → General → Workflow permissions → **Read and write permissions** 체크.
   (태그 push · ghcr push · 메모리 커밋에 필요)
3. **ghcr 패키지**: 별도 시크릿 불필요 — `GITHUB_TOKEN` 의 `packages: write` 로 동작. 최초 push 후
   패키지를 public 으로 바꾸려면 repo → Packages → 해당 패키지 → Package settings.
4. **`.dockerignore`** 작성 권장 (`.git`, `.worktrees`, `node_modules` 등 제외).

### 브랜치 보호와 메모리 자동 커밋 주의

`dev-ci.yml` 의 memory 잡은 `memory/MEMORY.md` 를 `dev` 에 직접 커밋(`[skip ci]`)합니다.
`dev` 에 "PR 필수 / push 제한" 브랜치 보호를 걸면 이 봇 커밋이 거부될 수 있습니다. 옵션:

- `dev` 는 status check 만 요구하고 Actions 봇 push 는 허용 (권장), 또는
- 메모리 잡을 제거하고 수동 `/memory add` 로 대체.

## 동작 요약

| 이벤트 | 워크플로 | 결과 |
|--------|---------|------|
| `feature/* → dev` 머지 | `dev-ci.yml` | `:latest-dev` + `:dev-<sha>` 빌드·push, `memory/MEMORY.md` 에 머지 기록 |
| `dev → main` 머지 | `release-promote.yml` | 버전 계산 → 이미지 승격(`:X.Y.Z`+`:latest-prd`) → git tag → GitHub Release |

## 검증

```bash
# 버전 계산 로직 단위 확인 (임시 repo)
git tag v1.2.3
git commit --allow-empty -m "feat: x"  && BUMP= bash next-version.sh   # → 1.3.0
git commit --allow-empty -m "fix: y"   && BUMP= bash next-version.sh   # → 1.3.0 (feat 우선)
BUMP=major bash next-version.sh                                        # → 2.0.0

# 승격 후 digest 동일성 확인
docker buildx imagetools inspect ghcr.io/<owner>/<repo>:latest-prd
docker buildx imagetools inspect ghcr.io/<owner>/<repo>:latest-dev    # 같은 digest 여야 함
```
