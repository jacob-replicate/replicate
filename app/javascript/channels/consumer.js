import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()
window.consumer = consumer;

export default consumer