_ = require "lodash"
React = require "react"
cx = require "react/lib/cx"
ReactCSSTransitionGroup = require "react/lib/ReactCSSTransitionGroup"

{div, input, textarea, select, option, i} = React.DOM

Input =
  propTypes:
    value: React.PropTypes.any
    onChange: React.PropTypes.func
    onFocus: React.PropTypes.func
    onBlur: React.PropTypes.func
    fieldState: React.PropTypes.string

  getInitialState: ->
    showIndicator: @props.showIndicator

InputElement =
  onChange: (e) ->
    @props.onChange e.target.value

  renderIndicator: ->
    className = null

    if @props.fieldState is "invalidInteractive"
      iconClass = "fa-times"
    else if @props.fieldState is "valid"
      iconClass = "fa-check"

    if iconClass
      indicator = i className: "fa #{iconClass}"
      return ReactCSSTransitionGroup transitionName: "fade", indicator

TextInput = React.createClass
  displayName: "TextInput"
  mixins: [Input, InputElement]

  render: ->
    div null,
      @transferPropsTo input
        onChange: @onChange
        className: cx
          "error": @props.fieldState is "invalid"
      @renderIndicator()

PasswordInput = React.createClass
  displayName: "PasswordInput"
  mixins: [Input, InputElement]

  render: ->
    div null,
      @transferPropsTo input
        type: "password"
        onChange: @onChange
        className: cx
          "error": @props.fieldState is "invalid"
      @renderIndicator()

TextareaInput = React.createClass
  displayName: "MultilineInput"
  mixins: [Input]

  onChange: (e) ->
    @props.onChange e.target.value

  render: -> @transferPropsTo textarea
    onChange: @onChange
    className: cx "error": @props.invalid

monthNames = ["January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December"]
monthMap = _.map monthNames, (month, n) -> [n, month]
currentYear = new Date().getFullYear()

# Month starts with 1
daysInMonth: (month, year) -> new Date(year, month, 0).getDate()

DateSelector = React.createClass
  displayName: "DateSelector"
  mixins: [Input]

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
  mixins: [Input]

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
  TextInput
  PasswordInput
  TextareaInput

  # A Selector is an Input for predefined values.
  DateSelector
  ChoiceSelector
}