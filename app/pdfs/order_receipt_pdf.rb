class OrderReceiptPdf
  def initialize(order:, order_items:)
    @order = order
    @order_items = order_items
    @helpers = ActionController::Base.helpers
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 36) do |pdf|
      configure_font(pdf)

      pdf.text "Order Receipt", size: 22, style: :bold
      pdf.move_down 14

      pdf.text "Order ID: #{@order.order_id}", size: 11
      pdf.text "Order Name: #{@order.order_name}", size: 11
      pdf.text "Status: #{@order.status}", size: 11
      pdf.text "Paid At: #{@order.updated_at.strftime("%Y-%m-%d %H:%M:%S")}", size: 11
      pdf.move_down 12

      pdf.stroke_horizontal_rule
      pdf.move_down 8
      pdf.text "Items", size: 12, style: :bold
      pdf.move_down 6

      @order_items.each_with_index do |item, index|
        pdf.text "#{index + 1}. #{item.product_name}", size: 11, style: :bold
        product_code = item.product_id.present? ? "P-#{item.product_id}" : "-"
        pdf.text "   Product Code: #{product_code} | Unit Price: #{currency(item.unit_price)} | Qty: #{item.quantity} | Subtotal: #{currency(item.subtotal)}", size: 10
        pdf.move_down 6
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 12
      pdf.text "Total Amount: #{currency(@order.amount)}", size: 12, style: :bold
      pdf.move_down 24
      pdf.text "Generated at #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}", size: 9, color: "6B7280"
    end.render
  end

  private

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
    @helpers.number_to_currency(value)
  end
end
