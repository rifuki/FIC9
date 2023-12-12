/**
 * order controller
 */

import axios from "axios";
import xenditHeader from "../helpers/header";
import { factories } from "@strapi/strapi";

export default factories.createCoreController(
  "api::order.order",
  ({ strapi }) => ({
    async create(ctx) {
      const result = await super.create(ctx);

      const payload = {
        external_id: result.data.id.toString(),
        payer_email: "aowkwok@gmail.com",
        description: "Payment for product",
        amount: result.data.attributes.totalPrice.toString(),
      };

      const response = await axios({
        url: "https://api.xendit.co/v2/invoices",
        headers: xenditHeader,
        data: payload,
      });

      // const response = await fetch("https://api.xendit.co/v2/invoices", {
      //   method: "POST",
      //   headers: xenditHeader,
      //   body: JSON.stringify(payload)
      // });

      // return response.json();
      return JSON.stringify(response);
    },
  })
);
