require "net/http"
require "json"

class TossPaymentsClient
  API_BASE = "https://api.tosspayments.com/v1".freeze

  def initialize(secret_key: ENV["TOSS_API_SECRET_KEY"].to_s)
    @secret_key = secret_key.to_s.strip
  end

  def confirm(payment_key:, order_id:, amount:)
    return { ok: false, error: "TOSS_API_SECRET_KEY가 비어 있습니다. API 개별 연동 시크릿 키(sk)를 설정하세요." } if @secret_key.blank?
    if widget_secret_key?(@secret_key)
      return { ok: false, error: "결제창 SDK에는 API 개별 연동 시크릿 키(sk)를 사용하세요. 결제위젯 키(gsk)는 지원하지 않습니다." }
    end

    uri = URI("#{API_BASE}/payments/confirm")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(@secret_key, "")
    request["Content-Type"] = "application/json"
    request.body = {
      paymentKey: payment_key,
      orderId: order_id,
      amount: amount
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    payload = JSON.parse(response.body)

    Rails.logger.info(
      "[TossCheckout] confirm_response " \
      "http_status=#{response.code} " \
      "order_id=#{order_id} " \
      "code=#{payload["code"]} " \
      "message=#{payload["message"]}"
    )

    if response.is_a?(Net::HTTPSuccess)
      { ok: true, payload: payload }
    else
      { ok: false, error: payload["message"] || "결제 승인 실패", payload: payload, http_status: response.code, code: payload["code"] }
    end
  rescue StandardError => e
    Rails.logger.error("[TossCheckout] confirm_exception class=#{e.class} message=#{e.message}")
    { ok: false, error: e.message, code: e.class.name }
  end

  private

  def widget_secret_key?(key)
    key.to_s.include?("_gsk_")
  end
end
