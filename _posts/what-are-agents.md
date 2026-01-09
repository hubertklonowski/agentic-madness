---
layout: post
title: "What are agents?"
date: 2026-01-09 18:00:00 +0100
categories: [ai, llm, agents]
tags: [agentic-ai, assistants, react, tools, retrieval, memory]
---

What if your AI could plan your vacation, manage your inbox, and solve problems without constant input?

# What are agents?

With the rise of the agentic AI, there now exist similar words that mean different things regarding what we have earlier called assistants.  
AI chatbots from pre-agentic era were often called assistants, but now it is misleading to use that word when talking about agents.

Let’s start by understanding the difference between assistant and an agent.

## Assistant

- Is not proactive, needs specific instructions on what needs to be done and requires user input if stuck on some step.
- Optimized for single-turn or short multi-turn tasks, it mostly executes predefined instructions.
- It can use pre-defined instructions and knowledge that it gained during the training (for LLMs). It is possible for assistant to use tools and retrieval, but it doesn’t work in an autonomous loop, it needs to be told when to stop.
- Is prone to hallucinations when asked about topics outside of the training data and knowledge gained from it.
- Can communicate with different assistants by itself but this capability is not usually built in, so usually when assistant cannot help, it hands off control to human assistant that will be able to help.

## Agent

- Is proactive, can work based on broad description of the problem and work out steps needed to achieve the goal by itself, without user input.
- Optimized for multi-turn tasks, can decide on its own when it is time to use a tool, when to use the memory or when to retrieve needed information.
- It doesn’t need pre-defined instructions on how to solve problems, and it can augment knowledge at runtime via retrieval with tools and persisting the state via memory. Because of that, it not only contains the knowledge from the time of the training but also can “reason” and adapt to a situation by augmenting via retrieval.
- Can be grounded via tools, which can reduce hallucinations, but they won’t be fully gone. It still requires verification, evaluation and guardrails for situation where it’s asked about topics outside of the training data, because of its tool-use and iteration capacities. Instead of making up an answer, it can check available sources.
- Can communicate with different agents via MCP protocol, which makes it even more extensible in problem solving.

## When to use agentic AI

Now that we know the difference, let’s try to understand when it would be a good idea to use agentic AI when creating solutions.

Some use cases include:

- Helping customers solve their issues to reduce load on human agents, e.g. helpdesk.
- Solving problems that require doing additional research and cannot be always defined in clearly defined list of steps, but rather a higher-level goal that needs to be achieved and can be achieved in different ways depending on what exactly needs to be done.
- Automation scenarios – whenever there is some task that is repeatable in how it needs to be done, there is a high chance that agent could perform such action, saving us precious time, e.g. booking a flight or online shopping
- More advanced workflows – things we do often that are specific to us, e.g. providing a summary of emails and categorizing them for us each day so that we can get through our inbox faster with possibility to ask questions about them.

## Agent operating model

You might be wondering how the agent operates underneath, so let me provide a short description on the agent operating model.

One of the popular patterns for how agents operate is called ReACT. It enables them to go through Think-Act-Observe cycles, where each of the steps enables them to improve task success by combining reasoning with tool-based grounding.

First the agent thinks on how to resolve the issue that was mentioned by user.  
Then it tries to act by doing some specific action, like web search to look up for additional information needed to resolve user’s issue.  
After acting, it tries to observe what effects an action it made had on the issue being solved, which is helpful to define next thing to think about.  
Then it goes through this cycle again, iterating and slowly getting closer to a solution.  
Because it is making observations, it is better able to identify the next thing worth thinking about and the next action that could be required (“act to reason” and “reason to action” describes it pretty well).

## What direction are we moving forward?

During 2025, it became popular to create tools for agents, so that they can help with some specific service or need. The more tools agents have, the more capable it might be in solving problems requiring knowledge outside of its knowledge base. The more active tools, the slower the interaction might be as interacting with GitHub Copilot while having multiple MCP servers and hundreds of tools enabled might show. Tools are being selected based on their description that we provide to the agent when defining such tool. We can equip agent in only the tools that are crucial to solve specific problem it needs to help with and this way we ensure that it won’t go into the wrong direction. For domain-specific knowledge, we can equip our agent with a custom knowledge base, so that it will have all the required information, it will be added to what the agent already knows.

Agentic capabilities look promising and it seems that as the time passes, we will be getting higher quality tools that will enable use to resolve our problems faster.  

Imagine an agent planning your vacation end-to-end while adjusting for weather and budget, it is now becoming a real possibility.
