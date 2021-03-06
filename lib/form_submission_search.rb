class FormSubmissionSearch
  include ActiveModel::Model
  class InvalidSearchError < StandardError
  end

  attr_accessor :start_date, :end_date, :form_action, :filters_applied, :status, :q
  validates :start_date, :end_date, date: true, allow_nil: true
  validates :form_action, presence: true
  validates_with DateRangeValidator, attributes: [:start_date, :end_date]

  def initialize(attributes={})

    q_to = /to:(\d{4}-\d{1,2}-\d{1,2})/
    q_from = /from:(\d{4}-\d{1,2}-\d{1,2})/
    q_status = /status:(\w+)/

    start_date =
      (m = q_from.match(attributes[:q])) ? m[1] : nil
    end_date =
      (m = q_to.match(attributes[:q])) ? m[1] : nil
    status =
      (m = q_status.match(attributes[:q])) ? m[1] : nil

    attributes = attributes.
      merge({start_date: start_date, end_date: end_date, status: status})

    super
    unless valid?
      raise InvalidSearchError.new(self.errors.messages)
    end
    @filters_applied ||= ""
  end

  def search
    submissions =
      FormSubmission
        .where(form_action_id: form_action.id)
        .order(:created_at)

    filter!(submissions)
  end

  private

  def filter!(submissions)
    filters =
      [start_date && method(:from), end_date && method(:to), status && method(:with_status)]

    filters.each do |filter|
      submissions = filter.call(submissions) unless filter.nil?
    end

    submissions
  end

  def from(submissions)
    @filters_applied += "from:#{start_date} "
    submissions.from_date(start_date)
  end

  def to(submissions)
    @filters_applied += "to:#{end_date} "
    submissions.until_date(end_date)
  end

  def with_status(submissions)
    case status
    when "unread"
      @filters_applied += "status:unread"
      submissions.unread
    when "read"
      @filters_applied += "status:read"
      submissions.read
    else
    submissions
    end
  end
end
