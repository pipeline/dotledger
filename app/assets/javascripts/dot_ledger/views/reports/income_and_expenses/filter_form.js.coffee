DotLedger.module 'Views.Reports.IncomeAndExpenses', ->
  class @FilterForm extends Backbone.Marionette.ItemView
    template: 'reports/income_and_expenses/filter_form'

    className: 'nav nav-pills nav-justified'

    tagName: 'ul'

    events:
      'click .period a': 'clickPeriod'

    onRender: ->
      @$el.find(".period.period-#{@model.get('period')}-days").addClass('active')

    clickPeriod: (event)->
      @model.set('period', $(event.target).data('period'))
      false
