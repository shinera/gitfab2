class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :memos, class_name: Card::Memo.name, cascade_callbacks: true
  embedded_in :project

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.memos = memos.map{|m| m.dup_document}
    end
  end
end