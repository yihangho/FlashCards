(function() {
  var CardStatisticsContainer = React.createClass({
    getInitialState: function() {
      return {data: null};
    },
    loadStatistics: function(id) {
      if (isNaN(parseInt(id))) return;

      $.get("/cards/" + id + "/statistics.json", function(data) {
        this.setState({data: data})
      }.bind(this))
    },
    render: function() {
      return (
        <div>
          <CardSelector cards={ this.props.cards } onCardSelected={ this.loadStatistics } />
          <Statistics data={ this.state.data } />
        </div>
      );
    }
  });

  var Statistics = React.createClass({
    componentDidMount: function() {
      this.initializeTooltip();
    },
    componentDidUpdate: function() {
      this.initializeTooltip();
    },
    initializeTooltip: function() {
      $(this.getDOMNode()).find('[data-toggle=tooltip]').tooltip();
    },
    render: function() {
      if (this.props.data) {
        var totalRevisions = this.props.data.thumbs_up_reviews.length + this.props.data.thumbs_down_reviews.length;

        return (
          <div>
            <div className="row">
              <div className="col-xs-6">Created</div>
              <div className="col-xs-6">
                <span data-toggle="tooltip" data-placement="bottom" title={ moment(this.props.data.created_at).format("ll") }>
                  { moment(this.props.data.created_at).fromNow() }
                </span>
              </div>
            </div>

            <div className="row">
              <div className="col-xs-6">Number of <i className="fa fa-thumbs-o-up" /></div>
              <div className="col-xs-6">{ this.props.data.thumbs_up_reviews.length }</div>
            </div>

            <div className="row">
              <div className="col-xs-6">Number of <i className="fa fa-thumbs-o-down" /></div>
              <div className="col-xs-6">{ this.props.data.thumbs_down_reviews.length }</div>
            </div>

            {
              this.props.data.last_revised_at &&

              <div className="row">
                <div className="col-xs-6">Last revised</div>
                <div className="col-xs-6">
                  <span data-toggle="tooltip" data-placement="bottom" title={ moment(this.props.data.last_revised_at).format("lll") }>
                    { moment(this.props.data.last_revised_at).fromNow() }
                  </span>
                </div>
              </div>
            }
          </div>
        );
      } else {
        return false;
      }
    }
  });

  var CardSelector = React.createClass({
    onCardSelected: function() {
      this.props.onCardSelected(this.refs.selector.getDOMNode().value);
    },
    render: function() {
      var cards   = this.props.cards;
      var options = Object.keys(cards).sort(function(a, b) {
        if (cards[a] < cards[b]) {
          return -1;
        } else if (cards[a] == cards[b]) {
          return 0;
        } else {
          return 1;
        }
      }).map(function(id) {
        return (
          <option key={ id } value={ id }>
            { cards[id] }
          </option>
        );
      });

      return (
        <select className="form-control" onChange={ this.onCardSelected } ref="selector">
          <option>Select a card</option>
          { options }
        </select>
      );
    }
  });

  $(document).on("page:load", function() {
    var container = document.getElementById("ReactCardStatistics");
    if (container) {
      React.render(
        <CardStatisticsContainer cards={JSON.parse(container.dataset.cards)} />,
        container
      );
    }
  });
})();
