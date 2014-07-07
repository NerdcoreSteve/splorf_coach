#It's a little worrying that .bucket-dropdown hides when .navbar-collapse shows
#This is what's required, but no javascript or html actually tells it to do this.
#It seems to be some happy-accident side effect

navbar_collapse_shown = false

$(document).on('show.bs.dropdown', '.bucket-dropdown', ( ->
    if navbar_collapse_shown
        $('.navbar-collapse').collapse('hide')
        navbar_collapse_shown = false
    $('.bucket-dropdown').dropdown()
))

$(document).on('show.bs.collapse', '.navbar-collapse', ( ->
    navbar_collapse_shown = true
))

#from http://stackoverflow.com/questions/20424477/responsive-sortable-list-supporting-drag-drop-for-bootstrap
#1, there's javascript stuff going on here I don't understand and
#2, it doesn't currently work
panel_list = $('#draggable-panel-list')
panel_list.sortable({
    handle: '.panel-heading', 
    update: ->
        $('.panel', panel_list).each( (index, elem) ->
            $listItem = $(elem)
            newIndex = $listItem.index()
        )
})
