#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

#TODO this code smells and isn't very DRY, make it better
#TODO try to make this more functional
#     if you're going to save state don't do it in fuctions
#     keep state info small and pass it through as parameters
#TODO learn rails js conventions
#TODO there's a lot of code that waits for the client to build html
#     this code could probably be avoided if that html were built
#     server-side
#TODO make sure you're using all of coffeescript's bells and whistles
#TODO hotkeys and click behavior should invoke the same code, this way
#     when you get one thing done you don't have to do the whole
#     thing over again for another control

current_dropdown_item = null

#TODO using setInterval like this really feels like a hack
#     but it's necessary to wait for some things
#     perhaps when I've learned events a bit better this
#     won't be necessary
wait_if_else = (seconds_to_wait, condition_function, true_function, false_function = null) ->
    checking_count = 0
    #indentation for setInterval's second parameter is
    #at the same indent level as variable
    checking = setInterval ->
        if condition_function()
            clearInterval(checking)
            true_function()
        else if checking_count > seconds_to_wait * 1000
            clearInterval(checking)
            if false_function != null then false_function()
        checking_count++
    , 1

focus_menu_item = (menu, options={}) ->
    which_li = 'first'
    if options.last then which_li = 'last'
    current_dropdown_item = $(menu).find('li:' + which_li).find('a')

    condition = -> menu.hasClass('open') or menu.parent().hasClass('open')

    if options.wait
        wait_if_else 1,
                     condition,
                     -> gui.focus(current_dropdown_item),
                     -> console.error "coudn't give focus to panel dropup item"
    else
        if condition()
            gui.focus(current_dropdown_item)

#TODO maybe behavior should be gradually refactored into this gui object
gui =
    focused_element: null
    focus: (element) ->
        gui.focused_element = element
        $(gui.focused_element).focus()
    unfocus: ->
        if gui.focused_element != null
            $(gui.focused_element).blur()
            gui.focused_element = null
    primary_panel:
        empty: ->
            $(gui.primary_panel.dom).length == 0
        description: null
        dropup:
            dom: null
            close: ->
                dropup_parent = $(gui.primary_panel.dropup.dom).parent()
                if $(dropup_parent).hasClass('open')
                    $(dropup_parent).removeClass('open')
                    current_dropdown_item = null
        dom: null
        change: (panel, scroll = true) ->
            if panel != gui.primary_panel.dom
                if gui.primary_panel.dom != null
                    gui.unfocus()
                    $(gui.primary_panel.dom).addClass 'panel-info'
                    $(gui.primary_panel.dom).removeClass 'panel-primary'
                
                gui.primary_panel.dom = panel
                $(gui.primary_panel.dom).removeClass 'panel-info'
                $(gui.primary_panel.dom).addClass 'panel-primary'

                gui.primary_panel.dropup.dom = $(gui.primary_panel.dom).find('.panel-dropup')
                gui.primary_panel.description = $(gui.primary_panel.dom).find('.panel-title').text()
                
                if scroll
                    scroll_to(gui.primary_panel.dom)

                #TODO if this works then I think I can delete
                #     similar lines elsewhere
                gui.primary_panel.focus_first_input()
        is_open: ->
            $(gui.primary_panel.dom).find('.panel-collapse').hasClass('in')
        focus_first_input: ->
            wait_if_else 1,
                         -> gui.primary_panel.is_open(),
                         -> gui.focus($(gui.primary_panel.dom).find('.panel-input:first'))

add_dropup_tab_mouse_behavior = (panel_input, panel_dropup) ->
    wait_if_else 1,
                 -> $(panel_dropup).children().length > 0,
                 ->
                     panel_dropup_items = $(panel_dropup).children()
                     for panel_dropup_item in panel_dropup_items
                         $(panel_dropup_item).keypress (e) ->
                             #TODO duplicate hotkey code
                             if get_hotkey_command(e) == '\t'
                                 e.preventDefault()
                                 panel_input.deactivate()
                                 if e.shiftKey
                                     panel_input.prev_input.activate()
                                 else
                                     panel_input.next_input.activate()
                 , ->
                    console.error "panel dropup is empty"
                 
tab_index = 0
append_bucket_item_panel = (index, bucket_item, collapsed=true) ->
    class_in_or_empty = ''
    if !collapsed
        class_in_or_empty = 'in'

    panel_description = "#{bucket_item['type']}: "
    variable_fields = ""
    move_to_button_or_empty = ""
    if bucket_item['type'] != 'Person'
        panel_description += "#{bucket_item['description']}"
        variable_fields = """
            <input id='first-input#{index}'
                   class='panel-input'
                   type='text'
                   value='#{bucket_item['description']}'
                   placeholder='description'><br>
        """
        move_to_button_or_empty = """
            <div class="btn-group panel-btn-group dropup">
                <button type="button" class="btn btn-default">
                    Move To
                </button>
                <button type="button"
                        class="btn btn-default dropdown-toggle panel-input"
                        data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
                </button>
                <ul class="panel-dropup dropdown-menu bucket-list"
                    role="menu">
                </ul>
            </div>
        """
    else
        panel_description += "#{bucket_item['first_name']} #{bucket_item['last_name']}"
        variable_fields = """
            <input id='first-input#{index}'
                   class='panel-input'
                   type='text'
                   value='#{bucket_item['first_name']}'
                   placeholder='first name'><br>
            <input class='panel-input'
                   type='text'
                   value='#{bucket_item['last_name']}'
                   placeholder='last name'><br>
        """
    bucket_item_panel = """
        <li  id='panel#{index}'
             class='panel panel-info'>
            <div class='panel-heading'
                 data-toggle='collapse'
                 data-parent='#accordion'
                 data-target='#collapse#{index}'>
                <h4 class='panel-title'>
                    #{panel_description}
                </h4>
            </div>
            <div id='collapse#{index}' class='panel-collapse collapse #{class_in_or_empty}'>
                <div class='panel-body'>
    """
    bucket_item_panel += variable_fields
    bucket_item_panel += """
                    <textarea class='panel-input'
                              placeholder='notes'>#{bucket_item['notes']}</textarea>
                    #{move_to_button_or_empty}
                    <button type='button'
                            class='btn btn-default panel-input'>
                        Save
                    </button>
                    <button type='button' 
                            class='btn btn-default panel-input'>
                        Cancel
                    </button>
                    <button type='button'
                            class="btn btn-default panel-input"
                            data-toggle="modal"
                            data-target="#remove-bucket-modal">
                        delete
                    </button>
                </div>
            </div>
        </li>
    """
    $('#sortable-bucket-item-list').append(bucket_item_panel)
    panel_inputs = $('#panel' + index).find('.panel-input')
    i = 0
    for panel_input in panel_inputs
        i_next = i + 1
        if i_next >= panel_inputs.length then i_next = 0
        panel_input.next_input = panel_inputs[i_next]

        i_prev = i - 1
        if i_prev < 0 then i_prev = panel_inputs.length - 1
        panel_input.prev_input = panel_inputs[i_prev]

        focus_last_dropup_item = (panel_dropup, options={}) ->
            current_dropdown_item = $(panel_dropup).find('li:last').find('a')
            if options.wait
                wait_if_else 1,
                             -> panel_dropup.parent().hasClass('open'),
                             -> gui.focus(current_dropdown_item),
                             -> console.error "coudn't give focus to panel dropup item"
            else
                if panel_dropup.parent().hasClass('open')
                    gui.focus(current_dropdown_item)

        if not $(panel_input).hasClass('dropdown-toggle')
            panel_input.deactivate = -> true
            panel_input.activate = ->
                gui.focus($(this))
        else
            panel = $(panel_input).parent()
            panel_dropup = $(panel).find(".panel-dropup")
            #TODO must be calling the wrong method but
            #     for now I am adding and removing the
            #     open class manually
            panel_input.deactivate = -> gui.primary_panel.dropup.close()

            panel_input.activate = ->
                if not $(panel).hasClass('open')
                    $(panel).addClass('open')
                    focus_menu_item panel_dropup, {last: true}
                
            add_dropup_tab_mouse_behavior(panel_input, panel_dropup)

            $(panel_input).click ->
                focus_menu_item panel_dropup, {wait: true, last: true}

        $(panel_input).keypress (e) ->
            if get_hotkey_command(e) == '\t'
                e.preventDefault()
                this.deactivate()
                if e.shiftKey
                    this.prev_input.activate()
                else
                    this.next_input.activate()

        i++

num_bucket_items = 0
populate_bucket_items = (bucket) ->
    $('#sortable-bucket-item-list').empty()
    $.ajax(type:"Post", url: "/mock/bucket_items", data:{'bucket':bucket}).done (json) ->
        $.each json, (index, bucket_item) -> 
            append_bucket_item_panel(index, bucket_item)
            num_bucket_items = index + 1

#TODO what about ajax failure?
#TODO duplicate code in next two functions
current_bucket = null
populate_bucket_dropdown_and_items = (bucket) ->
    current_dropdown_item = null
    current_bucket = bucket
    $.ajax(url: "/mock/buckets").done (json) ->
        $("#bucket-dropdown-head-text").empty().append bucket
        json.splice json.indexOf(bucket), 1
        $(".bucket-list").empty()
        $.each json, (index, bucket) ->
            $(".bucket-list").append "<li><a class='dropdown-item' href='#'>#{bucket}</a></li>"
    populate_bucket_items bucket

populate_new_panel_dropup = (new_panel) ->
    $.ajax(url: "/mock/buckets").done (json) ->
        json.splice json.indexOf(current_bucket), 1
        $.each json, (index, bucket) ->
            $(new_panel).append "<li><a class='dropdown-item' href='#'>#{bucket}</a></li>"

scroll_to = (element) ->
    if not gui.primary_panel.empty()
        $(window).scrollTop(element.position().top - parseInt($('body').css('padding-top')))

#TODO more duplicate code
close_move_to = () ->
    panel_dropup = $(gui.primary_panel.dom).find('.panel-dropup')
    panel = $(panel_dropup).parent()
    if panel.hasClass('open')
        $(panel).removeClass('open')

get_hotkey_command = (e) ->
    e = e or window.event
    return String.fromCharCode(e.which or e.charCode or e.keyCode)
    ''

set_panel_initial_focus = (panel) ->
    first_input = panel.find('.panel-collapse').find 'input'
    wait_if_else 1,
                 -> first_input.is ':visible',
                 -> gui.focus(first_input),
                 -> console.error "coudn't give focus to panel's first input"

#TODO I want a more generalized solution for tab/alt-tab cycle behavior
#     maybe wrap a div around them and then give that div an attribute
modal_button_tab_next = (e, button_id) ->
    if get_hotkey_command(e) == '\t'
        e.preventDefault()
        next_id = ''
        if button_id == '#delete-modal-delete-button'
            next_id = '#delete-modal-cancel-button'
        else if button_id == '#delete-modal-cancel-button'
            next_id = '#delete-modal-delete-button'
        gui.focus($(next_id))

$(document).on 'keypress', '#delete-modal-cancel-button', (e) ->
    modal_button_tab_next(e, '#delete-modal-cancel-button')

$(document).on 'keypress', '#delete-modal-delete-button', (e) ->
    modal_button_tab_next(e, '#delete-modal-delete-button')

$(document).on 'click', '.panel', () ->
    gui.primary_panel.change this, false

$(document).on 'hidden.bs.modal', '#remove-bucket-modal', -> gui.primary_panel.focus_first_input()

$(document).on 'show.bs.modal', '#remove-bucket-modal', ->
    $('#modal-bucket-item-description').text("\"#{gui.primary_panel.description}\"")

$(document).on 'shown.bs.modal', '#remove-bucket-modal', ->
    gui.focus($('#delete-modal-delete-button'))

#TODO why can't I do .click?
#     looks like I can do it under a $ ->
$(document).on 'click', '.panel-dropup > li > a', (e) ->
    e.preventDefault()
    alert "TODO moving items to different buckets not yet implemented"

$(document).on 'click', '#nav-bucket-dropdown > li > a', (e) ->
    e.preventDefault()
    $.when(populate_bucket_dropdown_and_items $(this).parent().text()).then ->
        gui.primary_panel.change $('#sortable-bucket-item-list').find('.panel:first')

#TODO more duplicate code
add_bucket_item = (bucket_item_type) ->
    bucket = 'New Stuff'
    num_bucket_items += 1
    if bucket_item_type != 'Person'
        bucket_item = {'type':bucket_item_type, 'description':'', 'notes':''}
    else
        bucket = 'People'
        bucket_item = {'type':bucket_item_type, 'first_name':'', 'last_name':'', 'notes':''}
    if current_bucket != bucket
        $.when(populate_bucket_dropdown_and_items bucket).then ->
            $.when(append_bucket_item_panel(num_bucket_items, bucket_item, false)).then ->
                gui.primary_panel.change $('#sortable-bucket-item-list').find('.panel:last')
                #TODO this next line should probably be in one place
                #     or maybe just a few. Atm, it's all over the place
                gui.primary_panel.focus_first_input()
    else
        $.when(append_bucket_item_panel(num_bucket_items, bucket_item, false)).then ->
            gui.primary_panel.change $('#sortable-bucket-item-list').find('.panel:last')
            if bucket_item_type != 'Person'
                populate_new_panel_dropup($(gui.primary_panel.dom).find('.panel-dropup'))
            gui.primary_panel.focus_first_input()

$(document).on 'click', '#plus-button-group > div > button', ->
    add_bucket_item $(this).attr('id')

navbar_collapse_shown = false

#TODO why can't I do $('.bucket-dropdown').on 'show.bs.dropdown' ?
#TODO can't I attach these functions directly to the elements in question?
$(document).on 'show.bs.dropdown', '.bucket-dropdown',  ->
    #TODO this separates click and hotkey behavior, bad
    close_move_to()
    if navbar_collapse_shown
        $('.navbar-collapse').collapse 'hide'
        navbar_collapse_shown = false
    $('.bucket-dropdown').dropdown
    focus_menu_item($('.bucket-dropdown'), {wait: true})

$(document).on 'show.bs.collapse', '.navbar-collapse', -> navbar_collapse_shown = true

$(document).on 'show.bs.collapse', '.panel-collapse', -> set_panel_initial_focus $(this).parent()

#TODO Why does this have to be inside a function?
$ -> 
    $("#sortable-bucket-item-list").sortable { cursor: "move", cancel:'.sorting_disabled' }
    $("#delete-modal-cancel-button").click ->
        $(gui.primary_panel.dom).remove()
        gui.primary_panel.change $('#sortable-bucket-item-list').find('.panel:first')

#TODO I'd like to do this for each class. There really ought to be a native way
#     to do this. Otherwise I suppose I could make a function for it.
#     or finally learn how to do this the proper rails way (with an attribute)

$(document).on 'mouseover', '.panel-input', ->
    $("#sortable-bucket-item-list").addClass('sorting_disabled')

$(document).on 'mouseout', '.panel-input', ->
    $("#sortable-bucket-item-list").removeClass('sorting_disabled')

$(document).on 'mouseover', '.panel-dropup', ->
    $("#sortable-bucket-item-list").addClass('sorting_disabled')

$(document).on 'mouseout', '.panel-dropup', ->
    $("#sortable-bucket-item-list").removeClass('sorting_disabled')

$(document).on 'click', '.bucket-dropdown-head', ->
    current_dropdown_item = null

#TODO initial dropdown population shouldn't be an ajax call
#TODO nor should it be tied to a hard-coded bucket name
#TODO maybe this should be done with partials that are rendered serverside on load
#TODO but on a click the html partials are requested for again.
#TODO the $(window).load is done to avoid a bug where if the page loses focus before
#TODO loading completes the ajax content isn't populated in the dropdown and item list
$(window).load ->
    $.when(populate_bucket_dropdown_and_items 'New Stuff').then ->
        gui.primary_panel.change $('#sortable-bucket-item-list').find('.panel:first')
    $(document).keypress (e) ->
        if not e.altKey
            return
        #TODO do a regex check for command and then override default behavior
        #     This should ensure no conflicts with browser hotkeys.
        switch get_hotkey_command(e)
            when 'l'
                if not $('.bucket-dropdown').hasClass 'open'
                    close_move_to()
                    $('.bucket-dropdown').addClass 'open'
                    focus_menu_item($('.bucket-dropdown'))
                else
                    $('.bucket-dropdown').removeClass 'open'
                    current_dropdown_item = null
            when 'k'
                if current_dropdown_item
                    prev_dropdown_item = current_dropdown_item.parent().prev().find('a')
                    if prev_dropdown_item.length != 0
                        current_dropdown_item = prev_dropdown_item
                        gui.focus(current_dropdown_item)
                else if $('.bucket-dropdown').hasClass('open')
                    focus_menu_item($('.bucket-dropdown'))
                else
                    if $(gui.primary_panel.dom).prev().length != 0
                        gui.primary_panel.change($(gui.primary_panel.dom).prev())
                    if $(gui.primary_panel.dom).find('.panel_collapse').hasClass('in')
                        set_panel_initial_focus gui.primary_panel.dom
            when 'j'
                if current_dropdown_item
                    next_dropdown_item = current_dropdown_item.parent().next().find('a')
                    if next_dropdown_item.length != 0
                        current_dropdown_item = next_dropdown_item
                        gui.focus(current_dropdown_item)
                else if $('.bucket-dropdown').hasClass('open')
                    focus_menu_item($('.bucket-dropdown'))
                else
                    if $(gui.primary_panel.dom).next().length != 0
                        gui.primary_panel.change($(gui.primary_panel.dom).next())
                    if $(gui.primary_panel.dom).find('.panel_collapse').hasClass('in')
                        set_panel_initial_focus gui.primary_panel.dom
            when 'K'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    gui.primary_panel.dom.insertBefore($(gui.primary_panel.dom).prev())
                    scroll_to(gui.primary_panel.dom)
                    set_panel_initial_focus gui.primary_panel.dom
            when 'J'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    gui.primary_panel.dom.insertAfter($(gui.primary_panel.dom).next())
                    scroll_to(gui.primary_panel.dom)
                    set_panel_initial_focus gui.primary_panel.dom
            when '\r'
                $(gui.primary_panel.dom).find('.panel-collapse').collapse('toggle')
                scroll_to(gui.primary_panel.dom)
                #TODO For some reason I think I might be doing the line below twice
                wait_if_else .1,
                             -> gui.primary_panel.is_open(),
                             -> gui.primary_panel.focus_first_input()
            when 'i'
                if $('#remove-bucket-modal').attr('aria-hidden') == "false"
                    gui.focus($('#delete-modal-delete-button'))
                else if $(gui.primary_panel.dom).find('.panel-collapse').hasClass('in')
                    gui.primary_panel.dropup.close()
                    gui.primary_panel.focus_first_input()
            when 't'
                #alt-t is tools in firefox, I'm choosing to override it for now...
                #TODO is this a jerk move?
                e.preventDefault()
                add_bucket_item 'Thing'
            when 'h'
                #alt-h appears to do the same thing as alt-b
                e.preventDefault()
                add_bucket_item 'Habit'
            when 'p'
                add_bucket_item 'Person'
            when 'd'
                #TODO is it ok that I'm overriding a hotkey that takes you to the address bar?
                #     Is it really better than alt-r, which is a bit to close to ctrl-r?
                e.preventDefault()
                $('#remove-bucket-modal').modal('show')
