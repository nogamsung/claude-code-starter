#!/bin/bash
# .claude/hooks/pre-push.sh
# Claude Code Pre-push 커버리지 게이트
#
# git push 명령어 감지 시 테스트를 실행하고 커버리지 90% 이상을 검증합니다.
# 미달 시 exit 1로 푸시를 차단하고 Claude가 테스트를 보강하도록 유도합니다.
#
# 지원 스택:
#   Kotlin Spring Boot → Jacoco (jacocoTestReport.xml)
#   Next.js            → Jest --coverage (coverage-summary.json)
#   Flutter            → flutter test --coverage (lcov.info)

INPUT=$(cat 2>/dev/null || echo '{}')

# stdin에서 실행 예정 명령어 추출
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo '')

# git push 가 아니면 즉시 통과 (다른 Bash 명령 성능에 영향 없음)
if [[ "$CMD" != *"git push"* ]]; then
  exit 0
fi

THRESHOLD=90
COVERAGE="0"
STACK="unknown"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " [Pre-push] 커버리지 게이트 (기준: ${THRESHOLD}%)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Kotlin Spring Boot (Jacoco) ─────────────────────────────
if [ -f "./gradlew" ]; then
  STACK="Kotlin Spring Boot"
  echo "[Pre-push] 스택: $STACK"
  echo "[Pre-push] ./gradlew test jacocoTestReport 실행 중..."
  echo ""

  if ! ./gradlew test jacocoTestReport --daemon -q 2>&1; then
    echo ""
    echo "[Pre-push] ❌ 테스트 실패 — 푸시 차단"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
  fi

  REPORT="build/reports/jacoco/test/jacocoTestReport.xml"
  if [ ! -f "$REPORT" ]; then
    echo "[Pre-push] ⚠️  Jacoco 리포트 없음: $REPORT"
    echo "           build.gradle.kts에 jacoco 플러그인이 설정되어 있는지 확인하세요."
    echo "           참고: https://docs.gradle.org/current/userguide/jacoco_plugin.html"
    exit 1
  fi

  COVERAGE=$(python3 - <<'PYEOF'
import xml.etree.ElementTree as ET, sys
try:
    root = ET.parse("build/reports/jacoco/test/jacocoTestReport.xml").getroot()
    counters = root.findall('.//counter[@type="LINE"]')
    missed   = sum(int(c.get("missed",  0)) for c in counters)
    covered  = sum(int(c.get("covered", 0)) for c in counters)
    total    = missed + covered
    print(f"{covered / total * 100:.1f}" if total > 0 else "0")
except Exception as e:
    print("0")
PYEOF
)

# ── Next.js (Jest + coverage) ───────────────────────────────
elif [ -f "package.json" ] && node -e "require('./package.json').dependencies?.next || require('./package.json').devDependencies?.next || process.exit(1)" 2>/dev/null; then
  STACK="Next.js"
  echo "[Pre-push] 스택: $STACK"
  echo "[Pre-push] npx jest --coverage 실행 중..."
  echo ""

  if ! npx jest --coverage --coverageReporters=json-summary --passWithNoTests 2>&1; then
    echo ""
    echo "[Pre-push] ❌ 테스트 실패 — 푸시 차단"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
  fi

  SUMMARY="coverage/coverage-summary.json"
  if [ ! -f "$SUMMARY" ]; then
    echo "[Pre-push] ⚠️  커버리지 리포트 없음: $SUMMARY"
    exit 1
  fi

  COVERAGE=$(node -e "
try {
  const d = JSON.parse(require('fs').readFileSync('coverage/coverage-summary.json','utf8'));
  console.log(d.total.lines.pct);
} catch(e) { console.log('0'); }
" 2>/dev/null || echo '0')

# ── Flutter (built-in coverage) ─────────────────────────────
elif [ -f "pubspec.yaml" ] && command -v flutter &>/dev/null; then
  STACK="Flutter"
  echo "[Pre-push] 스택: $STACK"
  echo "[Pre-push] flutter test --coverage 실행 중..."
  echo ""

  if ! flutter test --coverage 2>&1; then
    echo ""
    echo "[Pre-push] ❌ 테스트 실패 — 푸시 차단"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
  fi

  LCOV="coverage/lcov.info"
  if [ ! -f "$LCOV" ]; then
    echo "[Pre-push] ⚠️  커버리지 리포트 없음: $LCOV"
    exit 1
  fi

  COVERAGE=$(python3 - <<'PYEOF'
lf = lh = 0
try:
    with open("coverage/lcov.info") as f:
        for line in f:
            if line.startswith("LF:"):
                lf += int(line.strip().split(":")[1])
            elif line.startswith("LH:"):
                lh += int(line.strip().split(":")[1])
    print(f"{lh / lf * 100:.1f}" if lf > 0 else "0")
except:
    print("0")
PYEOF
)

# ── 알 수 없는 스택 ─────────────────────────────────────────
else
  echo "[Pre-push] ℹ️  지원 스택 감지 실패 — 커버리지 검사 건너뜀"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi

# ── 결과 판정 ───────────────────────────────────────────────
echo ""
echo "[Pre-push] 라인 커버리지: ${COVERAGE}%  (기준: ${THRESHOLD}%)"

PASS=$(python3 -c "
import sys
try:
    sys.exit(0 if float('${COVERAGE}') >= ${THRESHOLD} else 1)
except:
    sys.exit(1)
" 2>/dev/null && echo "yes" || echo "no")

if [ "$PASS" = "yes" ]; then
  echo "[Pre-push] ✅ 커버리지 통과 — 푸시 진행합니다"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "[Pre-push] ❌ 커버리지 ${COVERAGE}%가 기준 ${THRESHOLD}% 미만입니다."
  echo ""
  echo "  커버리지가 낮은 파일을 찾아 테스트를 추가하세요:"
  echo "    /test <파일경로>   # 테스트 자동 생성"
  echo ""
  echo "  테스트 추가 후 다시 git push를 시도하면 재검사합니다."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
