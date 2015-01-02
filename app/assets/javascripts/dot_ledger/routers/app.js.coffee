DotLedger.module 'Routers', ->
  class @App extends @Base
    routes:
      # Root
      '': 'root'

      # Accounts
      'accounts/new': 'newAccount'
      'accounts/:account_id/sort': 'sortAccount'
      'accounts/:account_id/edit': 'editAccount'
      'accounts/:account_id/import': 'newStatement'
      'accounts/:account_id': 'showAccount'
      'accounts/:account_id/:tab': 'showAccount'
      'accounts/:account_id/:tab/page-:page_number': 'showAccount'

      # Categories
      'categories': 'listCategories'
      'categories/new': 'newCategory'
      'categories/:id/edit': 'editCategory'

      # Sorting Rules
      'sorting-rules': 'listSortingRules'
      'sorting-rules/page-:page_number': 'listSortingRules'
      'sorting-rules/new': 'newSortingRule'
      'sorting-rules/:id/edit': 'editSortingRule'

      # Goals
      'goals': 'listGoals'

      # Payments
      'payments': 'listPayments'
      'payments/new': 'newPayment'
      'payments/:id/edit': 'editPayment'

      # Search
      'search/:params': 'search'
      'search/:params/page-:page_number': 'search'
      'search': 'search'

      # Reports
      'reports/income-and-expenses': 'incomeAndExpenses'

      # Not Found
      '*path': 'notFound'

    root: ->
      DotLedger.title 'Dashboard'

      dashboard = new DotLedger.Views.Application.Dashboard()

      DotLedger.mainRegion.show(dashboard)

      category_statistics = new (DotLedger.Collections.Base.extend({
        url: '/api/statistics/activity_per_category'
      }))

      category_statistics.fetch
        success: ->
          activity = new DotLedger.Views.Statistics.ActivityPerCategory.List(
            collection: category_statistics
          )
          dashboard.panelB.show(activity)

      accounts = new DotLedger.Collections.Accounts()
      accounts.fetch
        success: ->
          accounts_list = new DotLedger.Views.Accounts.List(collection: accounts)
          dashboard.panelA.show(accounts_list)

    notFound: (path)->
      model = new DotLedger.Models.Base
        path: path
      notFoundView = new DotLedger.Views.Application.NotFound
        model: model
      DotLedger.mainRegion.show(notFoundView)

    showAccount: (account_id, tab = 'sorted', page_number = 1)->
      account = new DotLedger.Models.Account(id: account_id)
      transactions = new DotLedger.Collections.Transactions()

      balances = new DotLedger.Collections.Balances()
      balances.fetch
        data:
          account_id: account_id
          date_from: moment().subtract('days', 90).format('YYYY-MM-DD')
          date_to: moment().format('YYYY-MM-DD')

      Backbone.history.navigate("/accounts/#{account_id}/#{tab}/page-#{page_number}")

      transactions.on 'page:change', (page)->
        Backbone.history.navigate("/accounts/#{account_id}/#{tab}/page-#{page}")

      switch tab
        when 'sorted'
          transactions.fetch
            data:
              account_id: account_id
              sorted: true
              review: false
              page: page_number

        when 'review'
          transactions.fetch
            data:
              account_id: account_id
              review: true
              page: page_number

        when 'unsorted'
          transactions.fetch
            data:
              account_id: account_id
              unsorted: true
              page: page_number

      show = new DotLedger.Views.Accounts.Show
        model: account
        balances: balances
        tab: tab

      account.fetch
        success: ->
          DotLedger.title 'Accounts', account.get('name')

          DotLedger.mainRegion.show(show)

          transactionsTableView = new DotLedger.Views.Transactions.Table(
            collection: transactions
          )

          show.transactions.show(transactionsTableView)

    newAccount: ->
      account = new DotLedger.Models.Account()
      form = new DotLedger.Views.Accounts.Form(model: account)

      form.on 'save', (model)->
        Backbone.history.navigate("/accounts/#{model.get('id')}", trigger: true)

      DotLedger.title 'New Account'

      DotLedger.mainRegion.show(form)

    sortAccount: (account_id)->
      $.ajax
        url: "/api/transactions/sort"
        data:
          account_id: account_id
        type: 'POST'
        success: (response)=>
          DotLedger.Helpers.Notification.success(response.message)
          @showAccount(account_id)

    editAccount: (account_id)->
      account = new DotLedger.Models.Account(id: account_id)
      form = new DotLedger.Views.Accounts.Form(model: account)

      account.fetch(
        success: ->
          DotLedger.title 'Edit Account', account.get('name')

          DotLedger.mainRegion.show(form)
      )

      form.on 'save', ->
        Backbone.history.navigate("/accounts/#{account_id}", trigger: true)

    newStatement: (account_id)->
      account = new DotLedger.Models.Account(id: account_id)
      statement = new DotLedger.Models.Statement()
      form = new DotLedger.Views.Statements.Form(model: statement, account: account)

      account.fetch
        success: ->
          DotLedger.title 'New Statement', account.get('name')

          DotLedger.mainRegion.show(form)

      form.on 'save', ->
        Backbone.history.navigate("/accounts/#{account_id}", trigger: true)

    listCategories: (page_number = 1) ->
      categories = new DotLedger.Collections.Categories()

      DotLedger.title 'Categories'

      categories.fetch
        success: ->
          list = new DotLedger.Views.Categories.List
            collection: categories

          DotLedger.mainRegion.show(list)

    newCategory: ->
      category = new DotLedger.Models.Category()
      form = new DotLedger.Views.Categories.Form(model: category)

      DotLedger.title 'New Category'

      form.on 'save', (model)->
        Backbone.history.navigate("/categories", trigger: true)

      DotLedger.mainRegion.show(form)

    editCategory: (category_id)->
      category = new DotLedger.Models.Category(id: category_id)
      form = new DotLedger.Views.Categories.Form(model: category)

      form.on 'save', (model)->
        Backbone.history.navigate("/categories", trigger: true)

      category.fetch
        success: ->
          DotLedger.title 'Edit Category', category.get('name')
          DotLedger.mainRegion.show(form)

    listSortingRules: (page_number = 1)->
      sorting_rules = new DotLedger.Collections.SortingRules()

      DotLedger.title 'Sorting Rules'

      sorting_rules.fetch
        data:
          page: page_number
        success: ->
          list = new DotLedger.Views.SortingRules.List
            collection: sorting_rules

          DotLedger.mainRegion.show(list)

      Backbone.history.navigate("/sorting-rules/page-#{page_number}")

      sorting_rules.on 'page:change', (page)->
        Backbone.history.navigate("/sorting-rules/page-#{page}")

    newSortingRule: ->
      sorting_rule = new DotLedger.Models.SortingRule()
      categories = new DotLedger.Collections.Categories()

      DotLedger.title 'New Sorting Rule'

      categories.fetch()

      form = new DotLedger.Views.SortingRules.Form
        model: sorting_rule
        categories: categories

      form.on 'save', (model)->
        Backbone.history.navigate("/sorting-rules", trigger: true)

      DotLedger.mainRegion.show(form)

    editSortingRule: (sorting_rule_id)->
      sorting_rule = new DotLedger.Models.SortingRule(id: sorting_rule_id)
      categories = new DotLedger.Collections.Categories()

      categories.fetch()

      form = new DotLedger.Views.SortingRules.Form
        model: sorting_rule
        categories: categories

      form.on 'save', (model)->
        Backbone.history.navigate("/sorting-rules", trigger: true)

      sorting_rule.fetch
        success: ->
          DotLedger.title 'Edit Sorting Rule', sorting_rule.get('contains')

          DotLedger.mainRegion.show(form)

    listGoals: ->
      goals = new DotLedger.Collections.Goals()

      DotLedger.title 'Goals'

      goals.fetch
        success: ->
          list = new DotLedger.Views.Goals.List
            collection: goals

          DotLedger.mainRegion.show(list)

    listPayments: ->
      payments = new DotLedger.Collections.Payments()

      DotLedger.title 'Payments'

      payments.fetch
        success: ->
          list = new DotLedger.Views.Payments.List
            collection: payments

          DotLedger.mainRegion.show(list)

    newPayment: ->
      payment = new DotLedger.Models.Payment()
      categories = new DotLedger.Collections.Categories()

      DotLedger.title 'New Payment'

      categories.fetch()

      form = new DotLedger.Views.Payments.Form
        model: payment
        categories: categories

      form.on 'save', (model)->
        Backbone.history.navigate("/payments", trigger: true)

      DotLedger.mainRegion.show(form)

    editPayment: (payment_id)->
      payment = new DotLedger.Models.Payment(id: payment_id)
      categories = new DotLedger.Collections.Categories()

      categories.fetch()

      form = new DotLedger.Views.Payments.Form
        model: payment
        categories: categories

      payment.fetch(
        success: ->
          DotLedger.title 'Edit Payment', payment.get('name')

          DotLedger.mainRegion.show(form)
      )

      form.on 'save', ->
        Backbone.history.navigate("/payments", trigger: true)

    search: (params = JSURL.stringify({}), page_number = 1)->
      search = new Backbone.Model(JSURL.parse(params))
      categories = new DotLedger.Collections.Categories()
      categories.fetch()

      search.on 'change', ->
        if search.has('query')
          DotLedger.title 'Search', search.get('query')
        else
          DotLedger.title 'Search'

      search.trigger 'change'

      tags = new DotLedger.Collections.Tags()
      tags.fetch()

      searchLayout = new DotLedger.Views.Search.Search()

      searchFilters = new DotLedger.Views.Search.FilterForm
        model: search
        categories: categories
        tags: tags

      transactions = new DotLedger.Collections.Transactions()

      Backbone.history.navigate("/search/#{params}/page-#{page_number}")

      transactions.on 'page:change', (page)->
        Backbone.history.navigate("/search/#{params}/page-#{page}")

      searchSummary = new DotLedger.Views.Search.Summary(
        collection: transactions
      )

      updateTransactions = (model, page = page_number)->
        params = JSURL.stringify(model.attributes)
        Backbone.history.navigate("/search/#{params}/page-#{page}")
        transactions.fetch(data: _.extend(model.attributes, page: page))

      searchFilters.on('search', updateTransactions)

      updateTransactions(search)

      searchResults = new DotLedger.Views.Transactions.Table(
        collection: transactions
      )

      DotLedger.mainRegion.show(searchLayout)
      searchLayout.searchFilters.show(searchFilters)
      searchLayout.searchSummary.show(searchSummary)
      searchLayout.searchResults.show(searchResults)

    incomeAndExpenses: ->
      DotLedger.title 'Reports', 'Income and Expenses'

      filter = new Backbone.Model()

      filterForm = new DotLedger.Views.Reports.IncomeAndExpenses.FilterForm
        model: filter

      reportView = new DotLedger.Views.Reports.IncomeAndExpenses.Show()

      category_statistics = new (DotLedger.Collections.Base.extend({
        url: '/api/statistics/activity_per_category'
      }))

      renderReport = ->
        filterForm.render()
        date_to = moment()
        date_from = moment().subtract(filter.get('period'), 'day')

        category_statistics.fetch
          data:
            date_to: date_to.format('YYYY-MM-DD')
            date_from: date_from.format('YYYY-MM-DD')
          success: ->
            activity = new DotLedger.Views.Reports.IncomeAndExpenses.Table(
              collection: category_statistics
            )
            reportView.report.show(activity)

      filter.on 'change:period', renderReport
      filter.set('period', 90)

      DotLedger.mainRegion.show(reportView)
      reportView.filterForm.show(filterForm)
