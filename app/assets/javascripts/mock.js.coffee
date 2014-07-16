#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect


append_bucket_item_panel = (index, bucket_item) ->
    panel_description = "#{bucket_item['type']}: "
    variable_fields = ""
    move_to_button_or_empty = ""
    if bucket_item['type'] != 'Person'
        panel_description += "#{bucket_item['description']}"
        variable_fields = """
            <input type='text' value='#{bucket_item['description']}' placeholder='description'><br>
        """
        move_to_button_or_empty = """
            <div class="btn-group">
                <button type="button" class="btn btn-default">
                    Move To
                </button>
                <button type="button"
                        class="btn btn-default dropdown-toggle"
                        data-toggle="dropdown">
                <span class="caret"></span>
                <span class="sr-only">Toggle Dropdown</span>
                </button>
                <ul id="panel-dropdown"
                    class="dropdown-menu bucket-dropdown-list"
                    role="menu">
                </ul>
            </div>
        """
    else
        if 'first_name' in bucket_item and 'last_name' in bucket_item
            panel_description += "#{bucket_item['first_name']} #{bucket_item['last_name']}"
        variable_fields = """
            <input type='text' value='#{bucket_item['first_name']}' placeholder='first name'><br>
            <input type='text' value='#{bucket_item['last_name']}' placeholder='last name'><br>
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
            <div id='collapse#{index}' class='panel-collapse collapse'>
                <div class='panel-body'>
    """
    bucket_item_panel += variable_fields
    bucket_item_panel += """
                    <textarea placeholder='notes'>#{bucket_item['notes']}</textarea>
                    <button type='button' class='btn btn-default'>
                        Save
                    </button>
                    <button type='button' class='btn btn-default'>
                        Cancel
                    </button>
                    #{move_to_button_or_empty}
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
populate_bucket_dropdown_and_items = (bucket) ->
    $.ajax(url: "/mock/buckets").done (json) ->
        $("#bucket-dropdown-head-text").empty().append bucket
        json.splice json.indexOf(bucket), 1
        $(".bucket-dropdown-list").empty()
        $.each json, (index, bucket) ->
            $(".bucket-dropdown-list").append "<li><a href='#'>#{bucket}</a></li>"
    populate_bucket_items bucket

#TODO why can't I do .click?
$(document).on 'click', '#panel-dropdown > li > a', (e) ->
    e.preventDefault()
    alert "TODO moving items to different buckets not yet implemented"

$(document).on 'click', '#nav-bucket-dropdown > li > a', (e) ->
    e.preventDefault()
    populate_bucket_dropdown_and_items $(this).parent().text()

$(document).on 'click', '#plus-button-group > div > button', (e) ->
    num_bucket_items += 1
    bucket_item_type = $(this).attr('id')
    if bucket_item_type != 'Person'
        bucket_item = {'type':bucket_item_type, 'description':'', 'notes':''}
    else
        bucket_item = {'type':bucket_item_type, 'first_name':'', 'last_name':'', 'notes':''}
    append_bucket_item_panel(num_bucket_items, bucket_item)

navbar_collapse_shown = false

#TODO why can't I do $('.bucket-dropdown').on 'show.bs.dropdown' ?
$(document).on 'show.bs.dropdown', '.bucket-dropdown',  ->
    if navbar_collapse_shown
        $('.navbar-collapse').collapse 'hide'
        navbar_collapse_shown = false
    $('.bucket-dropdown').dropdown

$(document).on 'show.bs.collapse', '.navbar-collapse', -> navbar_collapse_shown = true

#TODO Why does this have to be inside a function?
$ ->
    $("#sortable-bucket-item-list").sortable
    $("#sortable-bucket-item-list").sortable { cursor: "move" }

#TODO initial dropdown population shouldn't be an ajax call
#TODO nor should it be tied to a hard-coded bucket name
#TODO maybe this should be done with partials that are rendered serverside on load
#TODO but on a click the html partials are requested for again.
#TODO the $(window).load is done to avoid a bug where if the page loses focus before
#TODO loading completes the ajax content isn't populated in the dropdown and item list
$(window).load ->
    populate_bucket_dropdown_and_items 'New Stuff' 
