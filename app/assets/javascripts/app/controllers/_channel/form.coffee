# coffeelint: disable=no_unnecessary_double_quotes
class App.ChannelForm extends App.ControllerSubContent
  requiredPermission: 'admin.channel_formular'
  header: 'Form'
  events:
    'change form.js-params': 'updateParams'
    'keyup form.js-params': 'updateParams'
    'change .js-formSetting input': 'toggleFormSetting'

  elements:
    '.js-paramsBlock': 'paramsBlock'
    '.js-formSetting input': 'formSetting'

  constructor: ->
    super
    App.Setting.fetchFull(
      @render
      force: false
    )

  render: =>
    setting = App.Setting.get('form_ticket_create')
    @html App.view('channel/form')(
      baseurl: window.location.origin
      formSetting: setting
    )

    @paramsBlock.each (i, block) ->
      hljs.highlightBlock block

    @updateParams()

  updateParams: ->
    quote = (string) ->
      string = string.replace('\'', '\\\'')
        .replace(/\</g, '&lt;')
        .replace(/\>/g, '&gt;')
    params = @formParam(@$('.js-params'))
    paramString = ''
    for key, value of params
      if value != ''
        if paramString != ''
          paramString += ",\n"
        if value == 'true' || value == 'false'
          paramString += "    #{key}: #{value}"
        else
          paramString += "    #{key}: '#{quote(value)}'"
    @$('.js-modal-params').html(paramString)

    # rebuild preview
    params.test = true
    if params.modal
      @$('.js-formInline').addClass('hide')
      @$('.js-formBtn').removeClass('hide')
      @$('.js-formBtn').ZammadForm(params)
      @$('.js-formBtn').text('Feedback')
    else
      @$('.js-formBtn').addClass('hide')
      @$('.js-formInline').removeClass('hide')
      @$('.js-formInline').ZammadForm(params)

  toggleFormSetting: =>
    value = @formSetting.prop('checked')
    App.Setting.set('form_ticket_create', value)

App.Config.set('Form', { prio: 2000, name: 'Form', parent: '#channels', target: '#channels/form', controller: App.ChannelForm, permission: ['admin.formular'] }, 'NavBarAdmin')
