app_helpers
#########==

A collection of useful Rails application helpers and rake tasks.


Installation
------------

Add app_helper submodule

	git submodule add git@github.com:winton/app_helpers.git vendor/plugins/app_helpers
	
Copy resources (**app/views/app_helpers**)

	rake app_helpers


Rake Tasks
----------

### app_helpers

Installs **app/views/app_helpers**, which includes a few partials required by `Tbl` and `Template`.

### db:config

Prompts for a database name and generates **config/database.yml** for you.

### git:submodule

Runs `git:submodule:update`, and `git:submodule:pull`.

#### git:submodule:update

	git submodule init
	git submodule update

#### git:submodule:pull

Finds submodules in **app/widgets**, **config**, and **vendor/plugins** and runs

	git checkout master
	git pull

on each.


Partials
--------

### block_to_partial(partial_name, options = {}, &block)

Sends the output of a block to a partial as the local variable `body`.

Example:

	= block_to_partial 'some_partial', :locals => { :x => 0 } do
	  Two local variables will be sent to the partial; 'x' (0) and 'body' (this text).


### script_tag_redirect_to(url)

Renders an HTML javascript tag with the code `window.location=url`.


Tbl
---

### tbl(type, name, unit=nil, *widths, &block)

Uses the partials in **app/views/app_helpers/tbl** to generate CSS tables (rows of content with specific column widths).

Include the following in your site-wide SASS:

	.row
	  :overflow hidden
	  .parent
	    :float left
	    :display block

The view:

	- tbl :row, :your_identifier, :px, 100, 200, 300 do
	  - tbl :cell, :your_identifier do
	    Row 1, Cell 1
	  - tbl :cell, :your_identifier do
	    Row 1, Cell 2
	  - tbl :cell, :your_identifier do
	    Row 1, Cell 3
	  - tbl :cell, :your_identifier do
	    Row 2, Cell 1
	  - tbl :cell, :your_identifier do
	    Row 2, Cell 2
	  - tbl :cell, :your_identifier do
	    Row 2, Cell 3

*Note*: Change `:px` to `'%'` for percentage widths.

See [rails_widget](https://github.com/winton/rails_widget) for a javascript implementation of Tbl.


== Truncate

### better_truncate(text, length = 80, truncate_string = "...")

Like `truncate`, but does the job without cutting words in half.