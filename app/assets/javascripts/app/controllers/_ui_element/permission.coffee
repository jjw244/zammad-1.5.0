# coffeelint: disable=camel_case_classes
class App.UiElement.permission extends App.UiElement.ApplicationUiElement
  @render: (attribute, params = {}) ->

    permissions = App.Permission.search(sortBy: 'name')

    item = $( App.view('generic/permission')(
      attribute: attribute
      params: params
      permissions: permissions
    ) )

    # show/hide trees
    item.find('[name=permission_ids]').bind('change', (e) ->
      element = $(e.currentTarget)
      checked = element.prop('checked')
      permission_id = element.prop('value')
      return if !permission_id
      permission = App.Permission.find(permission_id)
      return if !permission
      if !permission.name.match(/\./)

        # show/hide sub permissions
        for localPermission in permissions
          regexp = new RegExp("^#{permission.name}")
          if localPermission.name.match(regexp)
            localElement = item.find("[name=permission_ids][value=#{localPermission.id}]").closest('.js-subPermissionList')
            if checked
              localElement.addClass('hide')
            else
              localElement.removeClass('hide')
      if checked && permission.preferences.not
        for localPermission in permission.preferences.not
          lookupPermission = App.Permission.findByAttribute('name', localPermission)
          if lookupPermission
            item.find("[name=permission_ids][value=#{lookupPermission.id}]").prop('checked', false)

    )

    item