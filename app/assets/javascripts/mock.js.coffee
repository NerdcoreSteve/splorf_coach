#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

navbar_collapse_shown = false

#TODO what about ajax failure?
populate_bucket_dropdown = (selected_bucket_index) ->
    $.ajax(url: "/mock/buckets").done (json) ->
        $("#bucket-dropdown-head-text").empty().append json[selected_bucket_index]
        json.splice selected_bucket_index, 1
        $("#ajax-list").empty
        $.each json, (index, bucket) ->
            $("#ajax-list").append "<li><a href='#'>#{bucket}</a></li>"

#TODO initial dropdown population shouldn't be an ajax call
populate_bucket_dropdown(1)

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
