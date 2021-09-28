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
class Invoice < ApplicationRecord
  has_one_attached :image
 
  def image_url
    if image.attached?
      image.blob.service_url
    end
  end

  def save_ocr_data
    use_ocr
    save
  end

  def use_ocr
    return if ocr_data

    textract = Aws::Textract::Client.new(region: 'eu-west-3')
    data = textract.detect_document_text({ document: {
                                           s3_object: {
                                             bucket: "factuscan",
                                             name: image.key
                                           }
                                         }
                              })
    extract_relevant_data(data)
  end

  def extract_relevant_data(data)
    result = {
      page:{},
      lines:[],
      words:[]
    }
    data[:blocks].each do | block |
      if block[:block_type] == "PAGE"
        result[:page][:width] = block.dig(:geometry,:bounding_box,:width)
        result[:page][:height] = block.dig(:geometry,:bounding_box,:height)
        next
      end
      if block[:block_type] == "LINE"
        text = build_text_info(block)
        result[:lines].append(text)
        next
      end
      if block[:block_type] == "WORD"
        text = build_text_info(block)
        result[:words].append(text)
        next
      end
    end
    self.ocr_data = result
  end

  def build_text_info(block)
    text = {}
    text[:width] = block.dig(:geometry,:bounding_box,:width)
    text[:height] = block.dig(:geometry,:bounding_box,:height)
    text[:left] = block.dig(:geometry,:bounding_box,:left)
    text[:top] = block.dig(:geometry,:bounding_box,:top)
    text[:confidence] = block[:confidence]
    text[:text] = block[:text]
    text
  end

  def assign_type
    use_ocr
    self.type = ocr_info.detect_type
    save
  end

  def ocr_info
    return @ocr_info if @ocr_info
    @ocr_info = OcrInfo.new(self.ocr_data)
  end

  def es_decimal(str_dec)
    return 0 unless str_dec

    str = str_dec.dup
    if str.size >2 && (str.rindex('.') == str.size - 3 || str.rindex(',') == str.size - 3)
      str[str.size - 3] = '#'
      str = str.gsub('.', '').gsub(',', '')
    end
    str.gsub('.', '').gsub(',', '.').gsub('#', '.').to_d
  end

  def to_s
    "<#{self.class.name} @id='#{id}' @type='#{type}' @invoice_date='#{invoice_date}' >"
  end

  def calculate_amount
    0
  end

  def check_calculations
    true
  end

  def fat
    0
  end
end
