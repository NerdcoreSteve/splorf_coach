#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

#TODO this code smells, make it better later
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
            <input class='panel-input'
                   type='text'
                   value='#{bucket_item['description']}'
                   placeholder='description'><br>
        """
        move_to_button_or_empty = """
            <div class="btn-group panel-btn-group dropup">
                <button type="button" class="btn btn-default panel-input">
                    Move To
                </button>
                <button type="button"
                        class="btn btn-default dropdown-toggle panel-input"
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
            <input class='panel-input'
                   type='text'
                   value='#{bucket_item['first_name']}'
                   placeholder='first name'><br>
            <input class='panel-input'
                   type='text'
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
                              placeholder='notes'>#{bucket_item['notes']}
                    </textarea>
                    #{move_to_button_or_empty}
                    <button type='button' class='btn btn-default panel-input'>
                        Save
                    </button>
                    <button type='button' class='btn btn-default panel-input'>
                        Cancel
                    </button>
                </div>
            </div>
        </li>
    """
    $('#sortable-bucket-item-list').append bucket_item_panel

num_bucket_items = 0
populate_bucket_items = (bucket) ->
    $('#sortable-bucket-item-list').empty()
    $.ajax(type:"Post", url: "/mock/bucket_items", data:{'bucket':bucket}).done (json) ->
        $.each json, (index, bucket_item) -> 
            append_bucket_item_panel(index, bucket_item)
            num_bucket_items = index + 1

#TODO what about ajax failure?
current_bucket = null
populate_bucket_dropdown_and_items = (bucket) ->
    current_bucket = bucket
    $.ajax(url: "/mock/buckets").done (json) ->
        $("#bucket-dropdown-head-text").empty().append bucket
        json.splice json.indexOf(bucket), 1
        $(".bucket-list").empty()
        $.each json, (index, bucket) ->
            $(".bucket-list").append "<li><a class='dropdown-item' href='#'>#{bucket}</a></li>"
    populate_bucket_items bucket

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
        $(window).scrollTop(primary_panel.position().top - parseInt($('body').css('padding-top')))

current_dropdown_item = null
focus_first_bucket_in_dropdown = ->
    current_dropdown_item = $('.bucket-dropdown').find('.dropdown-item:first')
    current_dropdown_item.focus()

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
$(document).on 'show.bs.dropdown', '.bucket-dropdown',  ->
    if navbar_collapse_shown
        $('.navbar-collapse').collapse 'hide'
        navbar_collapse_shown = false
    $('.bucket-dropdown').dropdown

$(document).on 'show.bs.collapse', '.navbar-collapse', -> navbar_collapse_shown = true

#TODO Why does this have to be inside a function?
$ -> $("#sortable-bucket-item-list").sortable { cursor: "move", cancel:'.sorting_disabled' }

$(document).on 'mouseover', '.panel-input', ->
    $("#sortable-bucket-item-list").addClass('sorting_disabled')

$(document).on 'mouseout', '.panel-input', ->
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
        switch String.fromCharCode(e.which || e.keyCode)
            when 'b'
                if not $('.bucket-dropdown').hasClass 'open'
                    $('.bucket-dropdown').addClass 'open'
                    focus_first_bucket_in_dropdown()
                else
                    $('.bucket-dropdown').removeClass 'open'
                    current_dropdown_item = null
            when 'p'
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
            when 'n'
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
