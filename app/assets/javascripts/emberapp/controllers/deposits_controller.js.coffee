Peatio.DepositsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()
    Peatio.set('deposits-controller', @)
    $.subscribe 'deposit:create', ->
      records = controller.get('model')[0].account().deposits()
      record = records.pop()
      controller.get('deposits').insertAt(0, record)
      $.subscribe 'deposit:update', (event, data) ->
        update_records = _.filter controller.get('deposits'), (r) ->
          r.id == data.id
        if update_records.length > 0
          update_records[0].set('aasm_state', data.attributes.aasm_state)
          if data.attributes.aasm_state != "submitting" and data.attributes.aasm_state != "submitted"
            $('#cancel_link').remove()

      setTimeout(->
        $('.deposit_item').first().addClass('new-row')
      , 500)

      if controller.get('deposits').length > 3
        setTimeout(->
          controller.get('deposits').popObject()
        , 1000)

    $.subscribe 'payment_address:create', ->
      $("#payment_address").html(controller.get('model')[0].account().payment_address)

  paymentAddress: (->
    @model[0].account().payment_address
  ).property('@each')

  btc: (->
    @model[0].currency == "btc"
  ).property('@each')

  cny: (->
    @model[0].currency == "cny"
  ).property('@each')

  btsx: (->
    @model[0].currency == "btsx"
  ).property('@each')

  pts: (->
    @model[0].currency == "pts"
  ).property('@each')

  dog: (->
    @model[0].currency == "dog"
  ).property('@each')

  deposits: (->
    @model[0].account().topDeposits()
  ).property('@each')

  fsources: (->
    FundSource.findAllBy('currency', @model[0].currency)
  ).property('@each')

  name: (->
    current_user.name
  ).property()

  deposit_channel_key: (->
    @model[0].key
  ).property('@each')

  actions: {
    submitDeposit: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#deposit_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: sum,  fund_source: fund_source }
      $('#deposit_cny_submit').attr('disabled', 'disabled')
      $.ajax({
        url: '/deposits/banks',
        method: 'post',
        data: { deposit: data }
      }).done(->
        $('#deposit_cny_submit').removeAttr('disabled')
      )

    cancelDeposit: ->
      record_id = event.target.dataset.id
      url = "/deposits/#{@model[0].key}s/#{record_id}"
      $.ajax({
        url: url
        method: 'DELETE'
      })
  }