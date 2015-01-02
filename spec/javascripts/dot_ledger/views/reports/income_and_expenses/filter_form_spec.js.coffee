describe "DotLedger.Views.Reports.IncomeAndExpenses.FilterForm", ->
  createView = (model = new Backbone.Model(period: 90))->

    view = new DotLedger.Views.Reports.IncomeAndExpenses.FilterForm(
      model: model
    )

    view

  it "should be defined", ->
    expect(DotLedger.Views.Reports.IncomeAndExpenses.FilterForm).toBeDefined()

  it "should use the correct template", ->
    expect(DotLedger.Views.Reports.IncomeAndExpenses.FilterForm).toUseTemplate('reports/income_and_expenses/filter_form')

  it "can be rendered", ->
    view = createView()
    expect(view.render).not.toThrow()

  it "sets the period to active", ->
    view = createView().render()
    expect(view.$el).toContainElement('.period.period-90-days.active')
