import { LightningElement, track, api } from "lwc";

export default class MultiSelectCombobox extends LightningElement {
  @api options;
  @api selectedValue;
  @api selectedValues = [];
  @api label;
  @api disabled = false;
  @api multiSelect = false;
  @track value;
  @track values = [];
  @track optionData;
  @track searchString;
  @track noResultMessage;
  @track showDropdown = false;

  @api addNew = false;

  connectedCallback() {
    this.showDropdown = false;
    var optionData = this.options
      ? JSON.parse(JSON.stringify(this.options))
      : null;
    var value = this.selectedValue
      ? JSON.parse(JSON.stringify(this.selectedValue))
      : null;
    var values = this.selectedValues
      ? JSON.parse(JSON.stringify(this.selectedValues))
      : null;
    if (value || values) {
      var searchString;
      var count = 0;

      values.forEach((val) => {
        let hasValue = false;
        optionData.forEach((option) => {
          if (option.value === val) {
            hasValue = true;
          }
        });

        if (!hasValue) {
          optionData.push({ value: val, label: val });
        }
      });

      for (var i = 0; i < optionData.length; i++) {
        if (this.multiSelect) {
          if (values.includes(optionData[i].value)) {
            optionData[i].selected = true;
            count++;
          }
        } else {
          if (optionData[i].value == value) {
            searchString = optionData[i].label;
          }
        }
      }
      if (this.multiSelect) this.searchString = count + " Option(s) Selected";
      else this.searchString = searchString;
    }

    console.log(value);
    console.log(values);
    console.log(optionData);

    this.value = value;
    this.values = values;

    this.optionData = optionData;
    // this.options
  }

  @api
  setOptions(options) {
    // console.log("this set options");
    // console.log(options);
    const optionData = options ? JSON.parse(JSON.stringify(options)) : null;
    optionData.forEach((option) => {
      option.selected = false;
    });
    this.value = "";
    this.values = [];
    this.optionData = optionData;
    this.searchString = "0 Option(s) Selected";
    console.log(this.optionData);
  }

  // get optionData() {
  //   return this.options;
  // }

  filterOptions(event) {
    this.searchString = event.target.value;
    if (this.searchString && this.searchString.length > 0) {
      this.noResultMessage = "";
      if (this.searchString.length >= 2) {
        var flag = true;
        for (var i = 0; i < this.optionData.length; i++) {
          if (
            this.optionData[i].label
              .toLowerCase()
              .trim()
              .includes(this.searchString.toLowerCase().trim())
          ) {
            this.optionData[i].isVisible = true;
            flag = false;
          } else {
            this.optionData[i].isVisible = false;
          }
        }
        if (flag) {
          this.noResultMessage =
            "No results found for '" + this.searchString + "'";
        }
      }
      this.showDropdown = true;
    } else {
      this.showDropdown = false;
    }
  }

  addItem(event) {
    const newItem = this.searchString;
    console.log(newItem);
    if (newItem) {
      var count = 0;
      var options = JSON.parse(JSON.stringify(this.optionData));

      options.push({ label: newItem, value: newItem, selected: true });
      this.values.push(newItem);
      console.log("here");
      for (var i = 0; i < options.length; i++) {
        // if (options[i].value === selectedVal) {
        //   if (this.multiSelect) {
        //     if (this.values.includes(options[i].value)) {
        //       this.values.splice(this.values.indexOf(options[i].value), 1);
        //     } else {
        //       this.values.push(options[i].value);
        //     }
        //     options[i].selected = options[i].selected ? false : true;
        //   } else {
        //     this.value = options[i].value;
        //     this.searchString = options[i].label;
        //   }
        // }

        if (options[i].selected) {
          count++;
        }
      }
      this.optionData = options;
      if (this.multiSelect) {
        this.searchString = count + " Option(s) Selected";

        let ev = new CustomEvent("selectoption", { detail: this.values });
        this.dispatchEvent(ev);
      }

      if (!this.multiSelect) {
        let ev = new CustomEvent("selectoption", { detail: this.value });
        this.dispatchEvent(ev);
      }

      // if (this.multiSelect) event.preventDefault();
      // else this.showDropdown = false;
      this.showDropdown = false;
    }
  }

  selectItem(event) {
    var selectedVal = event.currentTarget.dataset.id;
    console.log(selectedVal);
    if (selectedVal) {
      var count = 0;
      var options = JSON.parse(JSON.stringify(this.optionData));
      for (var i = 0; i < options.length; i++) {
        if (options[i].value === selectedVal) {
          if (this.multiSelect) {
            if (this.values.includes(options[i].value)) {
              this.values.splice(this.values.indexOf(options[i].value), 1);
            } else {
              this.values.push(options[i].value);
            }
            options[i].selected = options[i].selected ? false : true;
          } else {
            this.value = options[i].value;
            this.searchString = options[i].label;
          }
        }
        if (options[i].selected) {
          count++;
        }
      }
      this.optionData = options;
      if (this.multiSelect) {
        this.searchString = count + " Option(s) Selected";

        let ev = new CustomEvent("selectoption", { detail: this.values });
        this.dispatchEvent(ev);
      }

      if (!this.multiSelect) {
        let ev = new CustomEvent("selectoption", { detail: this.value });
        this.dispatchEvent(ev);
      }

      if (this.multiSelect) event.preventDefault();
      else this.showDropdown = false;
    }
  }

  showOptions() {
    if (this.disabled == false && this.options) {
      this.noResultMessage = "";
      this.searchString = "";
      var options = JSON.parse(JSON.stringify(this.optionData));
      for (var i = 0; i < options.length; i++) {
        options[i].isVisible = true;
      }
      if (options.length > 0) {
        this.showDropdown = true;
      }
      this.optionData = options;
    }
  }

  closePill(event) {
    var value = event.currentTarget.name;
    var count = 0;
    var options = JSON.parse(JSON.stringify(this.optionData));
    for (var i = 0; i < options.length; i++) {
      if (options[i].value === value) {
        options[i].selected = false;
        this.values.splice(this.values.indexOf(options[i].value), 1);
      }
      if (options[i].selected) {
        count++;
      }
    }
    this.optionData = options;
    if (this.multiSelect) {
      this.searchString = count + " Option(s) Selected";

      let ev = new CustomEvent("selectoption", { detail: this.values });
      this.dispatchEvent(ev);
    }
  }

  handleBlur() {
    var previousLabel;
    var count = 0;
    console.log("in blur?");
    for (var i = 0; i < this.optionData.length; i++) {
      if (this.optionData[i].value === this.value) {
        previousLabel = this.optionData[i].label;
      }
      if (this.optionData[i].selected) {
        count++;
      }
    }

    if (this.multiSelect) {
      this.searchString = count + " Option(s) Selected";
    } else {
      this.searchString = previousLabel;
    }

    this.showDropdown = false;
  }

  handleMouseOut() {
    //console.log("mouse out");
    // this.showDropdown = false;
  }

  handleMouseIn() {
    this.showDropdown();
  }
}