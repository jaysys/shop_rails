class AdminDailyOrdersPdf
  TABLE_COLUMNS = [
    { key: :order_id, label: "Order ID", width: 115, align: :left },
    { key: :user, label: "User", width: 70, align: :left },
    { key: :order_name, label: "Order Name", width: 126, align: :left },
    { key: :amount, label: "Amount", width: 70, align: :right },
    { key: :paid_at, label: "Paid At", width: 150, align: :left }
  ].freeze

  HEADER_HEIGHT = 28
  ROW_HEIGHT = 22

  def initialize(orders_by_date:, from_date:, to_date:)
    @orders_by_date = orders_by_date
    @from_date = from_date
    @to_date = to_date
    @helpers = ActionController::Base.helpers
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 32) do |pdf|
      configure_font(pdf)

      pdf.text "일자별 구매내역", size: 20, style: :bold
      pdf.move_down 8
      pdf.text "조회기간: #{range_text}", size: 11
      pdf.text "생성일시: #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}", size: 10, color: "6B7280"
      pdf.move_down 12

      if @orders_by_date.blank?
        pdf.text "결제완료 주문이 없습니다.", size: 11
      else
        @orders_by_date.each do |date, orders|
          ensure_space(pdf, 44)
          pdf.text date.strftime("%Y-%m-%d"), size: 14, style: :bold
          pdf.move_down 6
          pdf.text "총 #{orders.size}건, 합계 #{currency(orders.sum(&:amount))}", size: 10
          pdf.move_down 8

          draw_orders_table(pdf, orders)
          pdf.move_down 12
        end
      end
    end.render
  end

  private

  def draw_orders_table(pdf, orders)
    draw_header_row(pdf)

    orders.each do |order|
      ensure_space(pdf, ROW_HEIGHT) do
        draw_header_row(pdf)
      end

      values = {
        order_id: order.order_id.to_s,
        user: order.user&.name.to_s.presence || "(미연결)",
        order_name: order.order_name.to_s,
        amount: currency(order.amount),
        paid_at: order.updated_at.strftime("%Y-%m-%d %H:%M:%S")
      }

      draw_table_row(pdf, values, ROW_HEIGHT, bold: false)
      pdf.move_down ROW_HEIGHT
    end
  end

  def draw_header_row(pdf)
    ensure_space(pdf, HEADER_HEIGHT)

    y = pdf.cursor
    pdf.fill_color "F3F4F6"
    pdf.fill_rectangle [pdf.bounds.left, y], pdf.bounds.width, HEADER_HEIGHT
    pdf.fill_color "000000"

    labels = TABLE_COLUMNS.each_with_object({}) { |col, acc| acc[col[:key]] = col[:label] }
    draw_table_row(pdf, labels, HEADER_HEIGHT, bold: true)
    pdf.move_down HEADER_HEIGHT
  end

  def draw_table_row(pdf, values, height, bold:)
    x = pdf.bounds.left
    y = pdf.cursor

    TABLE_COLUMNS.each do |col|
      pdf.stroke_rectangle [x, y], col[:width], height
      pdf.fill_color "111111"
      pdf.text_box(
        values[col[:key]].to_s,
        at: [x + 4, y - 7],
        width: col[:width] - 8,
        height: height - 10,
        size: 9,
        style: bold ? :bold : :normal,
        overflow: :truncate,
        align: col[:align],
        valign: :center
      )
      x += col[:width]
    end
  end

  def ensure_space(pdf, required_height)
    return unless pdf.cursor < required_height

    pdf.start_new_page
    yield if block_given?
  end

  def range_text
    return "전체" unless @from_date && @to_date

    "#{@from_date.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")} ~ #{@to_date.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}"
  end

  def configure_font(pdf)
    candidates = [
      "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
      "/System/Library/Fonts/AppleGothic.ttf",
      "/Library/Fonts/Arial Unicode.ttf"
    ]

    font_path = candidates.find { |path| File.exist?(path) }
    return unless font_path

    pdf.font_families.update("Unicode" => { normal: font_path, bold: font_path })
    pdf.font("Unicode")
  end

  def currency(value)
    @helpers.number_to_currency(value, unit: "₩", precision: 0)
  end
end
