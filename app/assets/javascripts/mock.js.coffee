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
