DotLedger.module 'Views.Reports.IncomeAndExpenses', ->
  class @Show extends Backbone.Marionette.LayoutView
    template: 'reports/income_and_expenses/show'

    regions:
      filterForm: '#filter-form'
      report: '#report'
