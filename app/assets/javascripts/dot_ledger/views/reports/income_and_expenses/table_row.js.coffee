DotLedger.module 'Views.Reports.IncomeAndExpenses', ->
  class @TableRow extends Backbone.Marionette.ItemView
    template: 'reports/income_and_expenses/table_row'

    tagName: 'tr'

    templateHelpers: ->
      spentAmount: =>
        if @model.get('net') < 0
          DotLedger.Helpers.Format.money(-@model.get('net'))
      receivedAmount: =>
        if @model.get('net') > 0
          DotLedger.Helpers.Format.money(@model.get('net'))
