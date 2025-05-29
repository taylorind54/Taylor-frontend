<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SwiftFix Signup</title>
  <link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;600&display=swap" rel="stylesheet">
  <script src="https://js.stripe.com/v3/"></script>
  <style>
    body {
      font-family: 'Fredoka', sans-serif;
      margin: 0;
      padding: 0;
      background-color: #F2F2F7;
      color: #333;
    }
    header {
      background-color: #FFD60A;
      padding: 2rem;
      text-align: center;
      border-bottom: 4px solid #FF453A;
    }
    header h1 {
      margin: 0;
      font-size: 2.5rem;
      font-weight: 600;
    }
    header p {
      font-size: 1.2rem;
      margin-top: 0.5rem;
    }
    form {
      max-width: 400px;
      margin: 3rem auto;
      background: white;
      padding: 2rem;
      border-radius: 16px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    input, #card-element {
      width: 100%;
      padding: 0.75rem;
      margin-top: 1rem;
      margin-bottom: 1rem;
      border: 1px solid #ccc;
      border-radius: 8px;
      font-size: 1rem;
    }
    button {
      background-color: #FF453A;
      color: white;
      padding: 1rem;
      border: none;
      border-radius: 12px;
      font-size: 1.2rem;
      cursor: pointer;
      width: 100%;
      margin-top: 1rem;
    }
    .message {
      text-align: center;
      margin-top: 1rem;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <header>
    <h1>SwiftFix</h1>
    <p>Phone Protection That Clicks—Simple, Swift, Secure.</p>
  </header>

  <form id="subscription-form">
    <h2>Subscribe Now - $29.99/month</h2>
    <input type="text" id="username" placeholder="Username" required />
    <input type="email" id="email" placeholder="Email" required />
    <div id="card-element"></div>
    <button type="submit">Start Protection</button>
    <div class="message" id="message"></div>
  </form>

  <script>
    const stripe = Stripe("{{YOUR_PUBLISHABLE_KEY}}"); // Replace at runtime

    async function init() {
      const res = await fetch('/create-setup-intent');
      const { clientSecret } = await res.json();

      const elements = stripe.elements();
      const card = elements.create('card');
      card.mount('#card-element');

      const form = document.getElementById('subscription-form');
      const message = document.getElementById('message');

      form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const username = document.getElementById('username').value.trim();
        const email = document.getElementById('email').value.trim();

        if (!username || !email) {
          message.textContent = 'Please fill out all fields.';
          return;
        }

        // Confirm card setup
        const { setupIntent, error } = await stripe.confirmCardSetup(clientSecret, {
          payment_method: {
            card: card,
            billing_details: {
              name: username,
              email: email,
            },
          },
        });

        if (error) {
          message.textContent = error.message;
        } else {
          // Now call backend to create customer + subscription
          const res = await fetch('/create-subscription', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              username,
              email,
              paymentMethodId: setupIntent.payment_method
            })
          });

          const result = await res.json();
          if (result.success) {
            message.textContent = 'Subscription successful! You’re protected.';
          } else {
            message.textContent = result.error || 'Subscription failed.';
          }
        }
      });
    }

    init();
  </script>
</body>
</html>