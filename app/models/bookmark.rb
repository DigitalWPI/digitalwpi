# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :document, polymorphic: true
  has_many :bookmarks_categories, dependent: :destroy
  has_many :categories, through: :bookmarks_categories

  validates :user_id, presence: true

  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    value = super if defined?(super)
    value &&= value.constantize
    value || default_document_type
  end

  def default_document_type
    SolrDocument
  end
end