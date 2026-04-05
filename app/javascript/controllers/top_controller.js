import * as Rbase from "@app_root/app/javascript/rbase_common.js"
import { RbaseController } from "@app_root/app/javascript/rbase_stimulus.js"

export default class extends RbaseController {
  connect() {
    super.connect();
    $('table tbody tr').click(function(){
      var id = $(this).attr("data-id");
        location.href = '/top/' + id;
    });
  }
  
  index() {
    var self = this;
    
    $(function() {
      if (self.paramsValue.forward_url != null && self.paramsValue.forward_url != "") {
        // window.open(self.paramsValue.forward_url, '_blank', 'noopener');
        $("#sidebar_popup").attr("href", self.paramsValue.forward_url);
        setTimeout(function() {
          console.log("click:"+$("#sidebar_popup").attr("href"));
          $("#sidebar_popup").get(0).click()
        }, 500);
      }
    });
  }

  show() {
    var self = this;
    $(function() {
      if (self.paramsValue.forward_url != null && self.paramsValue.forward_url != "") {
        // window.open(self.paramsValue.forward_url, '_blank');
        $("#forward_url").attr("href", self.paramsValue.forward_url);
        // window.open(self.paramsValue.forward_url, '_blank', 'noopener');
        $("#sidebar_popup").attr("href", self.paramsValue.forward_url);
        setTimeout(function() {
          console.log("click:"+$("#sidebar_popup").attr("href"));
          $("#sidebar_popup").get(0).click()
        }, 500);
      }
    });
  }
}
