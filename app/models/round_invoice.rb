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
class RoundInvoice < Invoice

  def self.is_mine?(ocr_info)
    ocr_info.search_line("CANTIDAD DE REFERENCIA")
  end

  def calculate_amount
    self.amount = us_decimal(ocr_info.search_next_line_text('TOTAL A PERCIBIR'))
  end

  def us_decimal(str)
    return 0 unless str

    str[str.rindex('.')] = '#' if str.size >2 && str.rindex('.') == str.size - 3
    str.gsub(',', '').gsub('#', '.').to_d
  end

  def fat
    ocr_info.using_starts_with do
      amount = ocr_info.search_line_text('GRASA')
      if amount
        return es_decimal(amount[5..-1])
      end
    end
  end
end
