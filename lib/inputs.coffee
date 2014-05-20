React = require "react"

{div, input, textarea, select, option} = React.DOM

StringInput = React.createClass
  displayName: "FormStringInput"
  render: -> @transferPropsTo input()

PasswordInput = React.createClass
  displayName: "FormPasswordInput"
  render: -> @transferPropsTo input type: "password"

MultilineInput = React.createClass
  displayName: "FormMultilineInput"
  render: -> @transferPropsTo textarea()

monthNames = ["January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December"]
monthMap = _.map monthNames, (month, n) -> [n, month]
currentYear = new Date().getFullYear()

# Month starts with 1
daysInMonth: (month, year) -> new Date(year, month, 0).getDate()

DateSelector = React.createClass
  displayName: "DateSelector"

  getInitialState: ->
    date: new Date()

  onMonthChange: (month) ->
    date = @state.date
    # Ensure that the day is valid with the selected month.
    # Correct the day if it is invalid.
    year = @state.date.getFullYear()
    date.setDate Math.min date.getDate(), daysInMonth month, year
    date.setMonth month
    @setDate date

  onDayChange: (day) ->
    date = @state.date
    date.setDate day
    @setDate date

  onYearChange: (year) ->
    date = @state.date
    date.setFullYear year
    @setDate date

  setDate: (date) ->
    @setState {date}
    @onChange date

  renderMonthSelector: ->
    months = _.map monthMap, (month) -> option value: month[0], month[1]
    return select
      value: @state.date.getMonth()
      onChange: @onMonthChange
    , months

  renderDaySelector: ->
    days = [1..daysInMonth(@state.date.getMonth(), @state.date.getFullYear())]
    dayOptions = _.map days, (day) -> option value: day, day
    return select
      value: @state.date.getDate()
      onChange: @onDayChange
    , dayOptions

  renderYearSelector: ->
    years = _.map [currentYear..1900], (year) ->
      option value: year, year
    return select
      value: @state.date.getFullYear()
      onChange: @onYearChange
    , years

  render: ->
    div null,
      @renderMonthSelector()
      @renderDaySelector()
      @renderYearSelector()

componentMap =
  string: InputComponent
  password: FormPasswordInput
  multiline: FormMultilineInput
  date: DateSelector

module.exports = (type) -> componentMap[type]
