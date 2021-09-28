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
class TableInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("IMPORTE TOTAL LECHE")
  end

  def calculate_amount
    amount = ocr_info.search_prev_line_text('Euros')
    if amount
      self.amount = es_decimal(amount)
      return self.amount
    end
    ocr_info.using_ends_with do
      amount = ocr_info.search_line_text('Euros')
      if amount
        return es_decimal(amount[0..-6])
      end
    end
    nil
  end

  def fat
    ocr_info.using_included do
      amount = ocr_info.search_next_line_text('Materia Grasa')
      if amount
        return es_decimal(amount)
      end
    end
  end
end
