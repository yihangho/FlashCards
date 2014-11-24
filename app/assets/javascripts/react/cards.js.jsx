(function() {
  var CardsContainer = React.createClass({
    getInitialState: function() {
      return this.fromJSON(this.props.card);
    },
    fromJSON: function(json) {
      var card = JSON.parse(json);
      // Converts CSV to array
      ["synonyms", "antonyms"].forEach(function(k) {
        card[k] = card[k].split(/\s*,\s*/).filter(function(word) { return !!word; });
      });
      // Randomize the cards. Since we have small amount of cards (either 2 or 3)
      // we can just randomly pick a permutation rather than actually shuffle them.
      var permutations, availableCards;
      if (card.sentence) {
        permutations = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]];
        availableCards = ["word", "definition", "sentence"];
      } else {
        permutations = [[0, 1], [1, 0]];
        availableCards = ["word", "definition"];
      }
      var order;
      order = permutations[Math.floor(Math.random() * permutations.length)].map(function(idx, i) {
        return {
          type: availableCards[idx],
          visible: i == 0
        }
      });

      // And we're done
      return {
        card: card,
        order: order
      };
    },
    renderChild: function(description, i) {
      if (description.type == "word")
        return (<Word
          word={this.state.card.word}
          wordType={this.state.card.word_type}
          show={description.visible}
          key={description.type + "-" + i}
          />
        );
      else if (description.type == "definition")
        return (<Definition
          definition={this.state.card.definition}
          synonyms={this.state.card.synonyms}
          antonyms={this.state.card.antonyms}
          words={JSON.parse(this.props.words)}
          show={description.visible}
          key={description.type + "-" + i}
        />);
      else if (description.type == "sentence")
        return (<Sentence
          sentence={this.state.card.sentence}
          show={description.visible}
          key={description.type + "-" + i}
        />);
      else
        return false;
    },
    postScore: function(score) {
      $.ajax("/cards/rate/" + this.state.card.id, {
        type: "PATCH",
        data: {
          rating: score
        }
      });
    },
    fetchNewCard: function() {
      var suffix;
      if (window.location.pathname == "/") {
        suffix = "random.json";
      } else {
        suffix = ".json";
      }

      $(".spinner-container").removeClass("hidden");
      $(".spinner-container").spin();

      $.get(window.location.pathname + suffix, function(data) {
        this.setState(this.fromJSON(data));
        $(".spinner-container").addClass("hidden");
        $(".spinner-container").spin(false);
      }.bind(this), "text");
    },
    thumbUp: function(e) {
      e.preventDefault();
      this.postScore(1);
      this.fetchNewCard();
    },
    thumbDown: function(e) {
      e.preventDefault();
      this.postScore(-1);
      this.fetchNewCard();
    },
    showHint: function(e) {
      e.preventDefault();
      var state = this.state;
      for (var i = 0; i < state.order.length; i++) {
        if (!state.order[i].visible) {
          state.order[i].visible = true;
          break;
        }
      }
      this.setState(state);
    },
    componentDidUpdate: function() {
      $("html, body").animate({scrollTop: $(document).height()}, "slow");
    },
    render: function() {
      var moreCards = !this.state.order.every(function(x) {
        return x.visible;
      });
      return (
        <div>
          { this.state.order.map(this.renderChild) }
          <div className="thumbs-container">
            <a href="#" onClick={this.thumbUp} className="btn btn-success">
              <i className="fa fa-thumbs-o-up"></i>
            </a>
            <a href="#" onClick={this.showHint} className={ "btn btn-primary" + (moreCards ? "" : " disabled") }>
              Show Hint
            </a>
            <a href="#" onClick={this.thumbDown} className="btn btn-danger">
              <i className="fa fa-thumbs-o-down"></i>
            </a>
          </div>
        </div>
      );
    }
  });

  var Word = React.createClass({
    render: function() {
      var classNames = "well card" + (this.props.show ? "" : " hidden");
      return (
        <div className={classNames}>
        { this.props.word } (<i>{ this.props.wordType }</i>)
        </div>
      );
    }
  });

  var Definition = React.createClass({
    render: function() {
      var classNames = "well card" + (this.props.show ? "" : " hidden");

      var lists = ["synonyms", "antonyms"].map(function(k) {
        if (!this.props[k].length) return false;

        return [
          <p key={"p-" + k}>{ k.capitalize() }</p>,
          <ul key={"ul-" + k}>
          {
            this.props[k].map(function(word, i) {
              var children = word;
              if (this.props.words.bsearch(word)) {
                children = (
                  <a href={"/cards/" + word}>{ word }</a>
                );
              }
              return (
                <li key={ i }>
                  { children }
                </li>
              );
            }, this)
          }
          </ul>
        ];
      }, this);

      return (
        <div className={classNames}>
          { this.props.definition }
          { lists }
        </div>
      );
    }
  });

  var Sentence = React.createClass({
    render: function() {
      var classNames = "well card" + (this.props.show ? "" : " hidden");
      return (
        <div className={classNames}>{ this.props.sentence }</div>
      );
    }
  });

  $(document).on("page:load", function() {
    var container = document.getElementById("ReactCardContainer");
    if (container) {
      React.render(
        <CardsContainer card={container.dataset.card} words={container.dataset.words} />,
        container
      );
    }
  });

})();
