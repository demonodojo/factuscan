# == Schema Information
#
# Table name: invoices
#
#  id           :bigint           not null, primary key
#  invoice_date :date
#  ocr_data     :jsonb
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

  def use_ocr
    textract = Aws::Textract::Client.new(region: 'eu-west-3')
    data = textract.detect_document_text({ document: {
                                  s3_object: {
                                    bucket: "factuscan",
                                    name: image.key
                                  }
                                }
                              })
    extract_relevant_data(data)
    save
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
      end
      if block[:block_type] == "LINE"
        line = {}
        line[:width] = block.dig(:geometry,:bounding_box,:width)
        line[:height] = block.dig(:geometry,:bounding_box,:height)
        line[:left] = block.dig(:geometry,:bounding_box,:left)
        line[:top] = block.dig(:geometry,:bounding_box,:top)
        line[:confidence] = block[:confidence]
        line[:text] = block[:text]
        result[:lines].append(line)
      end
      if block[:block_type] == "WORD"
        word = {}
        word[:width] = block.dig(:geometry,:bounding_box,:width)
        word[:height] = block.dig(:geometry,:bounding_box,:height)
        word[:left] = block.dig(:geometry,:bounding_box,:left)
        word[:top] = block.dig(:geometry,:bounding_box,:top)
        word[:confidence] = block[:confidence]
        word[:text] = block[:text]
        result[:words].append(word)
      end
    end
    self.ocr_data = result
  end
end
