DotLedger.module 'Views.Reports.IncomeAndExpenses', ->
  class @Show extends Backbone.Marionette.LayoutView
    template: 'reports/income_and_expenses/show'

    regions:
      filter: '#filter'
      report: '#report'

    onShow: ->
      options = {
        lines: {
          show: true
        },
        points: {
          show: true
        },
        xaxis: {
          tickSize: [7, "day"],
          mode: "time"
        }
      }

      $.ajax
        url: "/api/statistics/activity_per_category_for_graph"
        dataType: "html"
        error: (jqXHR, textStatus, errorThrown) ->
          alert "AJAX Error: #{textStatus}"
        success: (series) ->
          ticks = []

          series = JSON.parse(series)
          for category in series
            do (category) ->
              for datapoint in category.data
                do (datapoint) ->
                  d = datapoint[0]
                  if d not in ticks
                    ticks.push(d)

          ticks.sort (a, b) ->
            return if a >=b then 1 else -1

          options['xaxis']['ticks'] = ticks

          $.plot("#income-expenses-graph", series, options)