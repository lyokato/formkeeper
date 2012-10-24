require 'spec_helper'

describe FormKeeper::Respondent do

  it "fills text form correctly" do
    filled = FormKeeper::Respondent.new.fill_up(<<-HTML, { 'username'=> "Andy >", 'password'=> "Hug", 'message'=> "Hello!<>" })
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<h1>Login</h1>
<form action="/api/post" method="post">
<input type="text" name="username" value="input your name here">
<input type="password" name="password">
<textarea name="message">foobar</textarea>
</form>
</body>
</html>
    HTML
    filled.should == <<-HTML
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<h1>Login</h1>
<form action="/api/post" method="post">
<input type="text" name="username" value="Andy &gt;" />
<input type="password" name="password" value="Hug" />
<textarea name="message">Hello!&lt;&gt;</textarea>
</form>
</body>
</html>
    HTML
  end

  it "checks checkboxes and radio-buttons correctly" do
    filled = FormKeeper::Respondent.new.fill_up(<<-HTML, { 'food'=> "1", 'media'=> ["1", "2"] })
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<h2>Choose your favarite</h2>
<label>Sushi</label><input type="radio" name="food" value="0" checked>
<label>Sake</label><input type="radio" name="food" value="1">
<label>Umeboshi</label><input type="radio" name="food" value="2">
<h2>Where did you know about this page?</h2>
<label>web site</label><input type="checkbox" name="media" value="0" checked>
<label>magazine</label><input type="checkbox" name="media" value="1">
<label>TV show</label><input type="checkbox" name="media" value="2">
</form>
</body>
</html>
    HTML
    filled.should == <<-HTML
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<h2>Choose your favarite</h2>
<label>Sushi</label><input type="radio" name="food" value="0" />
<label>Sake</label><input type="radio" name="food" value="1" checked="checked" />
<label>Umeboshi</label><input type="radio" name="food" value="2" />
<h2>Where did you know about this page?</h2>
<label>web site</label><input type="checkbox" name="media" value="0" />
<label>magazine</label><input type="checkbox" name="media" value="1" checked="checked" />
<label>TV show</label><input type="checkbox" name="media" value="2" checked="checked" />
</form>
</body>
</html>
    HTML
  end

  it "fills select-box form correctly" do
    filled = FormKeeper::Respondent.new.fill_up(<<-HTML, { 'favorite' => '1' })
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite">
  <option value="1">white</option>
  <option value="2">black</option>
  <option value="3" selected>blue</option>
</select>
</form>
</body>
</html>
    HTML
    filled.should == <<-HTML
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite">
  <option value="1" selected="selected">white</option>
  <option value="2">black</option>
  <option value="3">blue</option>
</select>
</form>
</body>
</html>
    HTML
  end

  it "fills multiple select-box form correctly" do
    filled = FormKeeper::Respondent.new.fill_up(<<-HTML, { 'favorite' => ['1', '2'] })
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite" multiple>
  <option value="1">white</option>
  <option value="2">black</option>
  <option value="3" selected>blue</option>
</select>
</form>
</body>
</html>
    HTML
    filled.should == <<-HTML
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite" multiple>
  <option value="1" selected="selected">white</option>
  <option value="2" selected="selected">black</option>
  <option value="3">blue</option>
</select>
</form>
</body>
</html>
    HTML
  end

  it "fills non-multiple select-box form correctly" do
    filled = FormKeeper::Respondent.new.fill_up(<<-HTML, { 'favorite' => ['1', '2'] })
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite">
  <option value="1">white</option>
  <option value="2">black</option>
  <option value="3" selected>blue</option>
</select>
</form>
</body>
</html>
    HTML
    filled.should == <<-HTML
<!DOCTYPE html SYSTEM>
<html>
<head>test</head>
<body>
<form action="/api/post" method="post">
<select name="favorite">
  <option value="1" selected="selected">white</option>
  <option value="2">black</option>
  <option value="3">blue</option>
</select>
</form>
</body>
</html>
    HTML
  end
end

