DotLedger.module 'Views.Reports.IncomeAndExpenses', ->
  class @Table extends Backbone.Marionette.CompositeView
    template: 'reports/income_and_expenses/table'

    getChildView: -> DotLedger.Views.Reports.IncomeAndExpenses.TableRow

    childViewContainer: "tbody"
