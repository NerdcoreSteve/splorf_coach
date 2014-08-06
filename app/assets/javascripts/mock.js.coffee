#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

#TODO maybe I need to make the whole gui an object....

#TODO this code smells and isn't very DRY, make it better
#TODO try to make this more functional
#     if you're going to save state don't do it in fuctions
#     keep state info small and pass it through as parameters
#TODO learn rails js conventions
#TODO there's a lot of code that waits for the client to build html
#     this code could probably be avoided if that html were built
#     server-side
#TODO make sure you're using all of coffeescript's bells and whistles

#TODO using setInterval like this really feels like a hack
#     but it's necessary to wait for some things
#     perhaps when I've learned events a bit better this
#     won't be necessary

gui =
    focused_element: null
    primary_panel: null

execute_after_true = (max_seconds, condition, function_to_execute) ->
    checking_count = 0
    #indentation for setInterval's second parameter is
    #at the same indent level as variable
    checking = setInterval ->
        if condition()
            clearInterval(checking)
            function_to_execute()
        else if checking_count > max_seconds * 1000
            clearInterval(checking)
            throw
                "max seconds passed unable to execute function\n #{function_to_execute.toString()}"
        checking_count++
    , 1

add_dropup_tab_mouse_behavior = (panel_input, panel_dropup) ->
    try
        execute_after_true 1, 
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
    catch error
        console.error error

current_dropdown_item = null
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
                        delete this item
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
                try
                    execute_after_true 1,
                                       -> panel_dropup.parent().hasClass 'open',
                                       -> current_dropdown_item.focus()
                catch error
                    console.error error
            else
                if panel_dropup.parent().hasClass('open')
                    current_dropdown_item.focus()

        if not $(panel_input).hasClass('dropdown-toggle')
            panel_input.deactivate = -> true
            panel_input.activate = ->
                $(this).focus()
        else
            panel = $(panel_input).parent()
            panel_dropup = $(panel).find(".panel-dropup")
            #TODO must be calling the wrong method but
            #     for now I am adding and removing the
            #     open class manually
            panel_input.deactivate = ->
                if $(panel).hasClass('open')
                    $(panel).removeClass('open')
                    current_dropdown_item = null

            panel_input.activate = ->
                if not $(panel).hasClass('open')
                    $(panel).addClass('open')
                    focus_last_dropup_item(panel_dropup)
                
            add_dropup_tab_mouse_behavior(panel_input, panel_dropup)

            $(panel_input).click ->
                focus_last_dropup_item $(panel).find(".panel-dropup"), {wait: true}

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
    $(window).scrollTop(element.position().top - parseInt($('body').css('padding-top')))

count = 0
make_primary_panel = (panel) ->
    if panel != gui.primary_panel
        if gui.primary_panel != null
            gui.primary_panel.addClass 'panel-info'
            gui.primary_panel.removeClass 'panel-primary'
        gui.primary_panel = panel
        gui.primary_panel.removeClass 'panel-info'
        gui.primary_panel.addClass 'panel-primary'
        scroll_to(gui.primary_panel)

#TODO more duplicate code
close_move_to = () ->
    panel_dropup = $(gui.primary_panel).find('.panel-dropup')
    panel = $(panel_dropup).parent()
    if panel.hasClass('open')
        $(panel).removeClass('open')

focus_first_bucket_in_dropdown = ->
    current_dropdown_item = $('.bucket-dropdown').find('.dropdown-item:first')
    current_dropdown_item.focus()

get_hotkey_command = (e) ->
    e = e or window.event
    return String.fromCharCode(e.which or e.charCode or e.keyCode)
    ''

set_panel_initial_focus = (panel) ->
    first_input = panel.find('.panel-collapse').find 'input'
    try
        execute_after_true 1,
                           -> first_input.is ':visible',
                           -> first_input.focus()
    catch error
        console.error error

$(document).on 'click', '.panel-heading', () -> make_primary_panel $(this).parent()

$(document).on 'shown.bs.modal', '#remove-bucket-modal', ->
    $('#cancel-delete-modal-button').focus()

#TODO why can't I do .click?
$(document).on 'click', '.panel-dropup > li > a', (e) ->
    e.preventDefault()
    alert "TODO moving items to different buckets not yet implemented"

$(document).on 'click', '#nav-bucket-dropdown > li > a', (e) ->
    e.preventDefault()
    $.when(populate_bucket_dropdown_and_items $(this).parent().text()).then ->
        make_primary_panel $('#sortable-bucket-item-list').find('.panel:first')

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
                make_primary_panel $('#sortable-bucket-item-list').find('.panel:last')
                #TODO this next line should probably be in one place
                #     or maybe just a few. Atm, it's all over the place
                gui.primary_panel.find('.panel-input:first').focus()
    else
        $.when(append_bucket_item_panel(num_bucket_items, bucket_item, false)).then ->
            make_primary_panel $('#sortable-bucket-item-list').find('.panel:last')
            if bucket_item_type != 'Person'
                populate_new_panel_dropup(gui.primary_panel.find('.panel-dropup'))
            gui.primary_panel.find('.panel-input:first').focus()

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

$(document).on 'show.bs.collapse', '.navbar-collapse', -> navbar_collapse_shown = true

$(document).on 'show.bs.collapse', '.panel-collapse', -> set_panel_initial_focus $(this).parent()

#TODO Why does this have to be inside a function?
$ -> $("#sortable-bucket-item-list").sortable { cursor: "move", cancel:'.sorting_disabled' }

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
        make_primary_panel $('#sortable-bucket-item-list').find('.panel:first')
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
                    focus_first_bucket_in_dropdown()
                else
                    $('.bucket-dropdown').removeClass 'open'
                    current_dropdown_item = null
            when 'k'
                if current_dropdown_item
                    prev_dropdown_item = current_dropdown_item.parent().prev().find('a')
                    if prev_dropdown_item.length != 0
                        current_dropdown_item = prev_dropdown_item
                        current_dropdown_item.focus()
                else if $('.bucket-dropdown').hasClass('open')
                    focus_first_bucket_in_dropdown()
                else
                    if gui.primary_panel.prev().length != 0
                        make_primary_panel(gui.primary_panel.prev())
                        #TODO NOW unfocus_panel_input(primary_panel)
                    if gui.primary_panel.find('.panel_collapse').hasClass('in')
                        set_panel_initial_focus gui.primary_panel
            when 'j'
                if current_dropdown_item
                    next_dropdown_item = current_dropdown_item.parent().next().find('a')
                    if next_dropdown_item.length != 0
                        current_dropdown_item = next_dropdown_item
                        current_dropdown_item.focus()
                else if $('.bucket-dropdown').hasClass('open')
                    focus_first_bucket_in_dropdown()
                else
                    if gui.primary_panel.next().length != 0
                        make_primary_panel(gui.primary_panel.next())
                    if gui.primary_panel.find('.panel_collapse').hasClass('in')
                        set_panel_initial_focus gui.primary_panel
            when 'K'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    gui.primary_panel.insertBefore(gui.primary_panel.prev())
                    scroll_to(gui.primary_panel)
                    set_panel_initial_focus gui.primary_panel
            when 'J'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    gui.primary_panel.insertAfter(gui.primary_panel.next())
                    scroll_to(gui.primary_panel)
                    set_panel_initial_focus gui.primary_panel
            when '\r'
                gui.primary_panel.find('.panel-collapse').collapse('toggle')
                scroll_to(gui.primary_panel)
                #TODO For some reason I think I might be doing the line below twice
                try
                    execute_after_true .1,
                                       -> gui.primary_panel.find('.panel-collapse').hasClass('in'),
                                       -> gui.primary_panel.find('.panel-input:first').focus()
                catch error
                    console.log 'primary panel not open, not gonna focus its input'
            when 'i'
                if $('#remove-bucket-modal').attr('aria-hidden') == "false"
                    $('#cancel-delete-modal-button').focus()
                else if gui.primary_panel.find('.panel-collapse').hasClass('in')
                    gui.primary_panel.find('.panel-input:first').focus()
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
