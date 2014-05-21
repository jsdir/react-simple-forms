_ = require "lodash"
React = require "react"

{div, input, textarea, select, option} = React.DOM

StringInput = React.createClass
  displayName: "StringInput"
  render: -> @transferPropsTo input()

PasswordInput = React.createClass
  displayName: "PasswordInput"
  render: -> @transferPropsTo input type: "password"

MultilineInput = React.createClass
  displayName: "MultilineInput"
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

ChoiceSelector = React.createClass
  displayName: "ChoiceSelector"

  propTypes:
    choices: React.PropTypes.object
    default: React.PropTypes.string
    onChange: React.PropTypes.func

  getInitialState: ->
    choice: null

  onChoiceSelect: (choice) ->
    @setState {choice}
    @props.onChange choice

  render: ->
    div className: "btn-group", _.map @props.choices, (choice) =>
      button
        onClick: => @onChoiceSelect choice
        className: "active" if @state.choice is choice
      , @props.choices[choice]

module.exports = {
  StringInput
  PasswordInput
  MultilineInput

  # A Selector is an Input for predefined values.
  DateSelector
  ChoiceSelector
}