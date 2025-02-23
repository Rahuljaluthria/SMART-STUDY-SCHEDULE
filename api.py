from openai import OpenAI

client = OpenAI(
  api_key="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"
)

completion = client.chat.completions.create(
  model="gpt-4o-mini",
  store=True,
  messages=[
    {"role": "user", "content": "write a haiku about ai"}
  ]
)

print(completion.choices[0].message);
