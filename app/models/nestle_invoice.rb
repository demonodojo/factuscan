# == Schema Information
#
# Table name: invoices
#
#  id           :bigint           not null, primary key
#  amount       :decimal(, )
#  invoice_date :date
#  ocr_data     :jsonb
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class NestleInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.lines[0][:text].start_with?("EMISO") &&  ocr_info.lines[0][:text].end_with?("AGADOR")
  end

  def calculate_amount
    self.amount = es_decimal(ocr_info.search_next_line_text('TOTAL TRANSFERENCIA'))
  end

  def fat
    ocr_info.using_included do
      amount = ocr_info.search_line_text('%M. G.')
      if amount
        return es_decimal(amount[-4..-1])
      end
    end
    nil
  end
end
