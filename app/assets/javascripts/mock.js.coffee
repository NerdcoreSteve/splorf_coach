#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

#TODO this code smells and isn't very DRY, make it better later
#TODO learn rails js conventions
#TODO panel-dropdown should be a class!!!
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
                   tabindex=#{1 + tab_index}
                   value='#{bucket_item['description']}'
                   placeholder='description'><br>
        """
        move_to_button_or_empty = """
            <div class="btn-group panel-btn-group dropup">
                <button type="button" class="btn btn-default panel-input">
                    Move To
                </button>
                <button type="button"
                        tabindex=#{4 + tab_index}
                        class="btn btn-default dropdown-toggle panel-input panel-dropup-button"
                        data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
                </button>
                <ul id="panel-dropdown"
                    class="dropdown-menu bucket-list panel-input"
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
                   tabindex=#{1 + tab_index}
                   value='#{bucket_item['first_name']}'
                   placeholder='first name'><br>
            <input class='panel-input'
                   type='text'
                   tabindex=#{2 + tab_index}
                   value='#{bucket_item['last_name']}'
                   placeholder='last name'><br>
        """
    bucket_item_panel = """
        <li class='panel panel-info'>
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
                              tabindex=#{3 + tab_index}
                              placeholder='notes'>#{bucket_item['notes']}</textarea>
                    #{move_to_button_or_empty}
                    <button type='button'
                            class='btn btn-default panel-input'
                            tabindex=#{5 + tab_index}>
                        Save
                    </button>
                    <button id='last-input#{index}'
                            type='button' 
                            class='btn btn-default panel-input'
                            tabindex=#{6 + tab_index}>
                        Cancel
                    </button>
                </div>
            </div>
        </li>
    """
    tab_index = tab_index + 6
    $('#sortable-bucket-item-list').append bucket_item_panel
    first_input_index = "#first-input#{index}"
    last_input_index = "#last-input#{index}"
    $(last_input_index).focusout -> $(first_input_index).focus()

num_bucket_items = 0
populate_bucket_items = (bucket) ->
    $('#sortable-bucket-item-list').empty()
    $.ajax(type:"Post", url: "/mock/bucket_items", data:{'bucket':bucket}).done (json) ->
        $.each json, (index, bucket_item) -> 
            append_bucket_item_panel(index, bucket_item)
            num_bucket_items = index + 1

#TODO what about ajax failure?
current_bucket = null
current_dropdown_item = null
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

scroll_to = (element) ->
    $(window).scrollTop(element.position().top - parseInt($('body').css('padding-top')))

count = 0
primary_panel = null
make_primary_panel = (panel) ->
    if panel != primary_panel
        if primary_panel != null
            primary_panel.addClass 'panel-info'
            primary_panel.removeClass 'panel-primary'
        primary_panel = panel
        primary_panel.removeClass 'panel-info'
        primary_panel.addClass 'panel-primary'
        scroll_to(primary_panel)

focus_first_bucket_in_dropdown = ->
    current_dropdown_item = $('.bucket-dropdown').find('.dropdown-item:first')
    current_dropdown_item.focus()

#TODO using setInterval like this really feels like a hack
#TODO but first_input is not initially visible
set_panel_initial_focus = (panel) ->
    first_input = panel.find('.panel-collapse').find('input')
    checking_count = 0
    #indentation for setInterval's second parameter is
    #at the same indent level as variable
    checking = setInterval ->
        if first_input.is(':visible') or checking_count > 1000
            clearInterval(checking)
            first_input.focus()
        checking_count++
    , 1

$(document).on 'click', '.panel-heading', () -> make_primary_panel $(this).parent()

#TODO why can't I do .click?
$(document).on 'click', '#panel-dropdown > li > a', (e) ->
    e.preventDefault()
    alert "TODO moving items to different buckets not yet implemented"

$(document).on 'click', '#nav-bucket-dropdown > li > a', (e) ->
    e.preventDefault()
    $.when(populate_bucket_dropdown_and_items $(this).parent().text()).then ->
        make_primary_panel $('#sortable-bucket-item-list').find('.panel:first')

$(document).on 'click', '#plus-button-group > div > button', (e) ->
    bucket = 'New Stuff'
    num_bucket_items += 1
    bucket_item_type = $(this).attr('id')
    if bucket_item_type != 'Person'
        bucket_item = {'type':bucket_item_type, 'description':'', 'notes':''}
    else
        bucket = 'People'
        bucket_item = {'type':bucket_item_type, 'first_name':'', 'last_name':'', 'notes':''}
    if current_bucket != bucket
        $.when(populate_bucket_dropdown_and_items bucket).then ->
            $.when(append_bucket_item_panel(num_bucket_items, bucket_item, false)).then ->
                make_primary_panel $('#sortable-bucket-item-list').find('.panel:last')
    else
        $.when(append_bucket_item_panel(num_bucket_items, bucket_item, false)).then ->
            make_primary_panel $('#sortable-bucket-item-list').find('.panel:last')

navbar_collapse_shown = false

#TODO why can't I do $('.bucket-dropdown').on 'show.bs.dropdown' ?
#TODO can't I attach these functions directly to the elements in question?
$(document).on 'show.bs.dropdown', '.bucket-dropdown',  ->
    if navbar_collapse_shown
        $('.navbar-collapse').collapse 'hide'
        navbar_collapse_shown = false
    $('.bucket-dropdown').dropdown

$(document).on 'show.bs.collapse', '.navbar-collapse', -> navbar_collapse_shown = true

#TODO using setInterval like this really feels like a hack
#TODO but first_input is not initially visible
$(document).on 'show.bs.collapse', '.panel-collapse', -> set_panel_initial_focus $(this).parent()

#TODO Why does this have to be inside a function?
$ -> $("#sortable-bucket-item-list").sortable { cursor: "move", cancel:'.sorting_disabled' }

$(document).on 'mouseover', '.panel-input', ->
    $("#sortable-bucket-item-list").addClass('sorting_disabled')

$(document).on 'mouseout', '.panel-input', ->
    $("#sortable-bucket-item-list").removeClass('sorting_disabled')

$(document).on 'click', '.bucket-dropdown-head', ->
    current_dropdown_item = null

$(document).on 'focusout', '.panel-dropup-button', ->
    panel_dropup_parent = $(this).parent()
    if panel_dropup_parent.hasClass('open')
        console.log 'close!'
        panel_dropup_parent.find('#panel-dropdown').toggle()

$(document).on 'focus', '.panel-dropup-button', ->
    panel_dropup_parent = $(this).parent()
    if not panel_dropup_parent.hasClass('open')
        console.log 'open!'
        panel_dropup = panel_dropup_parent.find('#panel-dropdown')
        panel_dropup.toggle()
        current_dropdown_item = panel_dropup.children().last().find('a')
        current_dropdown_item.focus()
        

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
        get_hotkey_command = (e) ->
            e = e or window.event
            if e.altKey
                return String.fromCharCode(e.which or e.charCode or e.keyCode)
            ''
        switch get_hotkey_command(e)
            when 'l'
                if not $('.bucket-dropdown').hasClass 'open'
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
                    if primary_panel.prev().length != 0
                        make_primary_panel(primary_panel.prev())
                    set_panel_initial_focus primary_panel
            when 'j'
                if current_dropdown_item
                    next_dropdown_item = current_dropdown_item.parent().next().find('a')
                    if next_dropdown_item.length != 0
                        current_dropdown_item = next_dropdown_item
                        current_dropdown_item.focus()
                else if $('.bucket-dropdown').hasClass('open')
                    focus_first_bucket_in_dropdown()
                else
                    if primary_panel.next().length != 0
                        make_primary_panel(primary_panel.next())
                    set_panel_initial_focus primary_panel
            when 'K'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    primary_panel.insertBefore(primary_panel.prev())
                    scroll_to(primary_panel)
                    set_panel_initial_focus primary_panel
            when 'J'
                if not current_dropdown_item and not $('.bucket-dropdown').hasClass('open')
                    primary_panel.insertAfter(primary_panel.next())
                    scroll_to(primary_panel)
                    set_panel_initial_focus primary_panel
            when '\r'
                primary_panel.find('.panel-collapse').collapse('toggle')
                scroll_to(primary_panel)
