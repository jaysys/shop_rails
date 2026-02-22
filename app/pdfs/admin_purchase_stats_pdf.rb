class AdminPurchaseStatsPdf
  TABLE_COLUMNS = [
    { key: :rank, label: "순위", width: 42, align: :center },
    { key: :product_name, label: "상품명", width: 239, align: :left },
    { key: :total_quantity, label: "구매 수량", width: 70, align: :right },
    { key: :order_count, label: "주문 건수", width: 70, align: :right },
    { key: :total_sales, label: "매출", width: 110, align: :right }
  ].freeze

  HEADER_HEIGHT = 24
  ROW_HEIGHT = 22

  def initialize(category_product_stats_grouped:, purchase_summary:, from_date:, to_date:)
    @grouped = category_product_stats_grouped
    @summary = purchase_summary
    @from_date = from_date
    @to_date = to_date
    @helpers = ActionController::Base.helpers
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 32) do |pdf|
      configure_font(pdf)

      pdf.text "구매 통계", size: 20, style: :bold
      pdf.move_down 8
      pdf.text "조회기간: #{range_text}", size: 11
      pdf.text "생성일시: #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}", size: 10, color: "6B7280"
      pdf.move_down 10

      pdf.text "대상 주문 수: #{@summary[:orders_count]}", size: 10
      pdf.text "총 판매 수량: #{@summary[:total_quantity]}", size: 10
      pdf.text "총 판매 금액: #{currency(@summary[:total_sales])}", size: 10
      pdf.move_down 12

      if @grouped.blank?
        pdf.text "조회기간 내 집계 가능한 구매 데이터가 없습니다.", size: 11
        next
      end

      @grouped.each do |category_name, rows|
        ensure_space(pdf, 64)
        pdf.start_new_page if pdf.cursor < 140 && pdf.page_number > 1

        pdf.text category_name, size: 14, style: :bold
        pdf.move_down 6
        pdf.text "총 #{rows.size}개 상품", size: 10
        pdf.move_down 8

        draw_category_table(pdf, rows)
        pdf.move_down 12
      end
    end.render
  end

  private

  def draw_category_table(pdf, rows)
    draw_header_row(pdf)

    rows.each_with_index do |row, idx|
      ensure_space(pdf, ROW_HEIGHT) do
        draw_header_row(pdf)
      end

      values = {
        rank: idx + 1,
        product_name: row.attributes["product_name"].to_s,
        total_quantity: row.attributes["total_quantity"].to_i,
        order_count: row.attributes["order_count"].to_i,
        total_sales: currency(row.attributes["total_sales"].to_f)
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
