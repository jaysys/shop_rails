# shop_rails

Rails 8 + SQLite 기반 쇼핑몰 예제입니다.

## 요구사항
- Ruby 3.3.x
- Bundler

## .env 설정 (필수)
이 프로젝트는 `dotenv-rails`로 환경변수를 로드합니다.

설정 순서:

```bash
cp .env.example .env
```

`.env` 파일을 열어 실제 값으로 수정합니다.

샘플:

```dotenv
# Toss Payments (API 개별 연동 키)
TOSS_API_CLIENT_KEY=test_ck_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
TOSS_API_SECRET_KEY=test_sk_XXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Mail / Alert
MAIL_FROM=yourid@gmail.com
MAIL_REPLY_TO=yourid@yourdomain.co.kr
APP_HOST=localhost:3000
COMPLAINT_STALE_HOURS=1

# SMTP (Gmail 예시)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=gmail.com
SMTP_USERNAME=yourid@gmail.com
SMTP_PASSWORD="abcd efgh ijkl mnop"
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

항목 설명:
- `TOSS_API_CLIENT_KEY`: 결제창 JS SDK용 클라이언트 키 (`_ck_` 포함)
- `TOSS_API_SECRET_KEY`: 결제 승인 API용 시크릿 키 (`_sk_` 포함)
- `MAIL_FROM`: 수신자에게 표시될 발신자 주소
- `MAIL_REPLY_TO`: 메일에서 회신(Reply) 시 기본 회신 주소
- `APP_HOST`: 메일 본문 링크 생성용 호스트 (`localhost:3000` 등)
- `COMPLAINT_STALE_HOURS`: 문의 미처리 알림 배치 기준 시간
- `SMTP_*`: 메일 발송 SMTP 계정/서버 정보

주의:
- Toss 키는 **결제위젯 키(`_gck_`, `_gsk_`)가 아니라 API 개별 연동 키**를 사용해야 합니다.
- Gmail 사용 시 `SMTP_PASSWORD`는 일반 비밀번호가 아니라 **앱 비밀번호**를 넣어야 합니다.
- 앱 비밀번호처럼 공백이 있는 값은 반드시 큰따옴표로 감싸세요.
- `.env`는 절대 Git에 커밋하지 마세요.

설정 확인:

```bash
bin/rails runner 'keys=%w[TOSS_API_CLIENT_KEY TOSS_API_SECRET_KEY MAIL_FROM MAIL_REPLY_TO APP_HOST SMTP_ADDRESS SMTP_PORT SMTP_DOMAIN SMTP_USERNAME SMTP_PASSWORD]; puts keys.map { |k| "#{k}=#{ENV[k].present? ? "OK" : "MISSING"}" }'
```

## 최초 1회 (One-shot)
프로젝트를 처음 받은 뒤 한 번에 실행:

```bash
bundle install
bin/rails s
```

현재 프로젝트는 `bin/rails s` 실행 시 DB 파일이 없으면 자동으로 `db:prepare`를 수행합니다.

## 서비스 기동 방법
기본 웹 서버 실행:

```bash
bin/rails s
```

브라우저 접속:
- `http://localhost:3000`

Solid Queue를 Puma 내부에서 같이 실행(개발용):

```bash
SOLID_QUEUE_IN_PUMA=true bin/rails s
```

Solid Queue를 별도 프로세스로 실행(권장):

```bash
# 터미널 1
bin/rails s

# 터미널 2
bin/jobs start
```

## 서비스 종료 방법
- 포그라운드 실행 중이면 해당 터미널에서 `Ctrl + C`
- 서버와 잡을 분리해 실행했다면 각 터미널에서 각각 `Ctrl + C`

## 백그라운드 실행 방법
웹 서버를 백그라운드로 실행:

```bash
nohup bin/rails s > log/server.out 2>&1 &
```

잡 워커를 백그라운드로 실행:

```bash
nohup bin/jobs start > log/jobs.out 2>&1 &
```

백그라운드 프로세스 확인:

```bash
ps aux | grep -E "bin/rails s|bin/jobs start" | grep -v grep
```

백그라운드 프로세스 종료:

```bash
pkill -f "bin/rails s"
pkill -f "bin/jobs start"
```

## 참고
- 환경변수는 `.env` 파일을 사용합니다.
- 처음부터 전체 초기화/설치가 필요하면 `bin/setup`을 사용할 수 있습니다.
