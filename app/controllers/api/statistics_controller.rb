# FIXME: This needs some work

module Api
  class StatisticsController < BaseController
    include DateRangeParams

    def activity_per_category
      @activity_per_category = Statistics::ActivityPerCategory.new(date_range)
      set_metadata_header(
        date_from: date_range.first,
        date_to: date_range.last,
        total_spent: @activity_per_category.total_spent,
        total_received: @activity_per_category.total_received,
        total_net: @activity_per_category.total_net
      )
      render json: @activity_per_category
    end

    def activity_per_category_for_graph
      details = Category.find_by_sql("SELECT categories.type AS cat_type, EXTRACT(WEEK FROM transactions.posted_at) as week, abs(sum(amount)) as amount FROM sorted_transactions LEFT JOIN categories ON categories.id = category_id LEFT JOIN transactions ON transactions.id = transaction_id WHERE transactions.posted_at > date_trunc('day', NOW() - interval '3 months') GROUP BY categories.type, week ORDER BY week;")

      categories = {}

      details.each do |row|
        categories[row.cat_type] ||= []
        time  = Time.new(Date.current.year, 1, 1, 1)
        cweek = Date.current.cweek
        time  = Time.new(Date.current.year - 1, 1, 1, 1) if row.week > cweek
        time += (row.week * 7).days
        timestamp = time.to_i.to_s + '000'
        categories[row.cat_type] << [timestamp, row.amount]
      end

      data = []
      categories.each do |key, value|
        data << {
            label: key,
            data:  value
        }
      end

      render json: data
    end
  end
end
