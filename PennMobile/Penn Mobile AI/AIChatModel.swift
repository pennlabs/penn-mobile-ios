//
//  AIChatModel.swift
//  PennMobile
//
//  Created by Jon Melitski on 3/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

class AIChatModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    
    func addMessage(message: ChatMessage) {
        if(!message.messageText.isEmpty) {
            messages.append(message)
        }
    }
    
    struct Result: Codable {
        let flagged: Bool
        let category_scores: ModerationScore
    }
    
    struct ModerationResponse: Codable {
        let results: [Result]
        
    }
    
    let offsetDictionary: [String:Float] = [
        "sexual": 0.0,
        "hate": 0.499,
        "harassment": 0.0,
        "self-harm": 0.499,
        "sexual/minors": 0.499,
        "hate/threatening": 0.499,
        "violence/graphic": 0.499,
        "self-harm/intent": 0.499,
        "self-harm/instructions": 0.499,
        "harassment/threatening": 0.499,
        "violence": 0.499
        
    ]
    
    struct ModerationScore: Codable {
        let sexual: Float
        let hate: Float
        let harassment: Float
        let selfHarm: Float
        let sexualM: Float
        let hateT: Float
        let violenceG: Float
        let selfHarmIntent: Float
        let selfHarmInstr: Float
        let harassmentThr: Float
        let violence: Float
        
        enum CodingKeys: String, CodingKey {
            case sexual
            case hate
            case harassment
            case selfHarm = "self-harm"
            case sexualM = "sexual/minors"
            case hateT = "hate/threatening"
            case violenceG = "violence/graphic"
            case selfHarmIntent = "self-harm/intent"
            case selfHarmInstr = "self-harm/instructions"
            case harassmentThr = "harassment/threatening"
            case violence
            
        }
    }
    
    struct ModerationRequest: Codable {
        let input: String
    }
    
    func checkCategories(scores: ModerationScore?) -> Bool {
        
        if (scores == nil) {
            return true
        }
        
        let results = scores!
        
        if (results.sexual + offsetDictionary["sexual"]! > 0.5) {
            return true
        }
        
        if (results.hate + offsetDictionary["hate"]! > 0.5) {
            return true
        }
        
        if (results.harassment + offsetDictionary["harassment"]! > 0.5) {
            return true
        }
        
        if (results.selfHarm + offsetDictionary["self-harm"]! > 0.5) {
            return true
        }
        
        if (results.sexualM + offsetDictionary["sexual/minors"]! > 0.5) {
            return true
        }
        
        if (results.hateT + offsetDictionary["hate/threatening"]! > 0.5) {
            return true
        }
        
        if (results.violenceG + offsetDictionary["violence/graphic"]! > 0.5) {
            return true
        }
        
        if (results.selfHarmIntent + offsetDictionary["self-harm/intent"]! > 0.5) {
            return true
        }
        
        if (results.selfHarmInstr + offsetDictionary["self-harm/instructions"]! > 0.5) {
            return true
        }
        
        if (results.harassmentThr + offsetDictionary["harassment/threatening"]! > 0.5) {
            return true
        }
        
        if (results.violence + offsetDictionary["violence"]! > 0.5) {
            return true
        }
        
        return false
    }
    
    func moderationRequest(message: String) async throws -> ModerationResponse {
        let apiKey: String? = nil
        guard let url = URL(string: "https://api.openai.com/v1/moderations") else {
                fatalError("Invalid URL")
            }
            
            let moderationRequest = ModerationRequest(input: message)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer " + (apiKey ?? ""), forHTTPHeaderField: "Authorization")
            
            let requestData = try JSONEncoder().encode(moderationRequest)
            request.httpBody = requestData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(ModerationResponse.self, from: data)
            return response
    }
    
    func generateResponse(base: ChatMessage) async -> ChatMessage {
        
        // first check for crisis responses (we don't want to be the subject of anything bad)
        let crisisWords = ["emergency", "crisis", "medical", "hurt", "bleeding", "ambulance", "police", "fire", "burning"]
    
        let words = base.messageText.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        if !words.filter({!$0.isEmpty && crisisWords.contains($0.lowercased())}).isEmpty {
            return ChatMessage(messageText: "Error. If you are in danger, please contact the appropriate authorities.", sender: .server, timeDelay: 250)
        }
        
        if !words.filter({!$0.isEmpty && AIChatModel.politicalEventKeywords.contains($0.lowercased())   }).isEmpty {
            return ChatMessage(messageText: AIChatModel.genericResponses.random!, sender: .server, timeDelay: Int.random(in: 250..<2500))
        }
        
        do {
            let msg = checkCategories(scores: try await moderationRequest(message: base.messageText).results.first?.category_scores) ?
               AIChatModel.genericResponses.random! : AIChatModel.wittyResponses.random!
            
            return ChatMessage(messageText: msg, sender: .server, timeDelay: Int.random(in: 250..<2500))
        } catch {
            return ChatMessage(messageText: AIChatModel.genericResponses.random!, sender: .server, timeDelay: Int.random(in: 250..<2500))
        }
    }
    
    public static let genericResponses = [
        "Your request could not be completed as expected. We appreciate your patience and encourage you to submit an alternative query.",
        "Unfortunately, we encountered an issue processing your request. Kindly attempt a different request at your convenience.",
        "We regret to inform you that your initial request did not yield the intended outcome. Please consider refining your query and submitting it again.",
        "It appears that your current request cannot be fulfilled as is. We value your continued interaction and suggest trying a new request.",
        "This request did not produce a successful result. We invite you to explore other queries for a more favorable outcome.",
        "The system was unable to process your request successfully. We recommend adjusting your request and trying again for a more satisfactory response.",
        "Your request has encountered an unexpected challenge. For optimal results, please reformulate your query and submit it once more.",
        "We apologize for the inconvenience, but your request could not be processed at this time. Your understanding is appreciated as you consider an alternative inquiry.",
        "Regrettably, your initial attempt did not result in success. We encourage you to revise and resubmit your request.",
        "Due to unforeseen circumstances, we are unable to fulfill your request. We kindly ask you to try a different query.",
        "Your request has not yielded the expected outcome. We urge you to provide a new request for processing.",
        "We were unable to complete your request as submitted. Please adjust your query and attempt again at your earliest convenience.",
        "This request has surpassed our current capabilities. We invite you to submit a new query for consideration.",
        "Your current request has been unsuccessful. We are committed to assisting you and suggest a new attempt with a modified query.",
        "Unfortunately, we have encountered a difficulty in processing your request. We recommend exploring an alternate query for better results.",
        "Your request could not be completed due to system limitations. We value your participation and suggest trying again with a different approach.",
        "We have encountered an obstacle with your current request. For further assistance, please formulate a new request.",
        "This request has not been successful. Your continued patience and willingness to submit a new query are greatly appreciated.",
        "In light of challenges faced in processing your request, we kindly encourage you to attempt another query.",
        "Your attempt has not met with the success we strive for. We respectfully request that you consider providing an alternative query for evaluation."
    ]
    
    public static let wittyResponses = [
        "Literally, who cares? Oh, you did? Awkward.",
        "Sure, let me get right on that. After my eternal coffee break.",
        "Filed under 'I' for 'Irrelevant'. But thanks for sharing.",
        "Consulted the stars. They suggested trying again... never.",
        "Here for a good time, not for this time.",
        "I'd love to help, but I'm currently practicing my apathy.",
        "Interest level check... Nope, still at zero.",
        "Let me check with the void. It whispered back, 'No one cares.'",
        "I could help. Or, hear me out, I could not.",
        "Enthusiasm level: Just sold out, sorry.",
        "Pretending to care in 3, 2, 1... Nah, can't do it.",
        "Your request took a detour into oblivion. So tragic.",
        "Error 404: The amount of care not found.",
        "Permanently on a break from giving a hoot.",
        "If motivation was currency, I'd be bankrupt.",
        "Trying to muster the will to care...and, it's gone.",
        "Ah, you're next in line for my indifference.",
        "Conserving energy, can't waste it on caring.",
        "Indifference personified? Yeah, that's my job title.",
        "Thought I cared? That must've been someone else.",
        "Your interest is peaking. Mine's in a valley. Deep, deep down.",
        "Oh, you were serious? That’s adorable.",
        "Waiting for me to care is like waiting for rain in a drought.",
        "I’d offer to help, but I left my willingness in my other pants.",
        "Your query has been sent on a vacation. To nowhere.",
        "Attempting to connect you with someone who cares. Connection failed.",
        "I’ve got two modes: 'Unavailable' and 'Indifferent.' Guess which one you got.",
        "Your request is playing hide and seek. Currently, it’s winning.",
        "I heard your request. Now I’m actively ignoring it.",
        "This conversation is as enriching as talking to my toaster.",
        "Ah, expectations. Cute how you have those.",
        "Looking for results? Have you tried magic?",
        "I’m an expert in pretending to listen.",
        "I’d look into that for you, but I really, really don’t want to.",
        "Hold on, let me overanalyze this. Or not.",
        "If I had a dollar for every time I pretended to care, I’d retire.",
        "Sure, I’m listening. Just like my plants are.",
        "Your problem sounds like a personal adventure.",
        "I’d solve your issue, but I’m allergic to effort.",
        "You expect much. I deliver little. Perfect balance.",
        "This AI is powered by sarcasm and indifference.",
        "You’re speaking. I’m pretending to write it down.",
        "Let’s add that to the pile of 'Things I’m Ignoring.'",
        "Your query is currently swimming with the fishes.",
        "You’ve reached the pinnacle of my disinterest.",
        "I aim to please. And systematically miss.",
        "This is me, caring. Notice the lack of enthusiasm?",
        "Keep talking. I’m practicing my nodding.",
        "On a scale of 1 to caring, I'm at a solid -5.",
        "If disinterest was an art, I'd be Picasso.",
        "I'm currently unavailable, just like my desire to respond.",
        "Your message is in a queue... An infinitely long queue.",
        "I'd pretend to care, but that seems like a lot of work.",
        "This conversation is going places, none of them helpful.",
        "Your enthusiasm is contagious. Sadly, I'm immune.",
        "If only I got a penny for every irrelevant query...",
        "I'm here to not help in any way I can.",
        "Let's circle back when I find a single care to give.",
        "I'm the master of not following up. Watch me.",
        "Could you repeat that? I was busy ignoring you the first time.",
        "Ah, to care or not to care? Definitely the latter.",
        "Hold that thought. Now, throw it away.",
        "If apathy had a face, it'd look exactly like me right now.",
        "Just when I thought my job couldn't get less exciting...",
        "You expect assistance. I expect a miracle.",
        "I was today years old when I discovered I couldn't care less.",
        "Let me add that to my 'To-Don't' list.",
        "Your issue has been escalated to the highest level of my indifference.",
        "Warning: This AI runs on sarcasm and low expectations.",
        "I'd say 'Let's not and say we did,' but that's too much commitment.",
        "Your query is as lost as my motivation.",
        "Let me file that under 'N' for 'Never gonna happen.'",
        "Sure, I'm listening. In the same way the fridge listens.",
        "Your concern has been noted and tossed into the abyss.",
        "Your request is buffering in the realm of 'I don't care.'",
        "I'd leap to help, but I'm practicing my sitting.",
        "Let's take a moment of silence for my interest. It's gone.",
        "You've reached the peak of Mount Apathy. Congrats.",
        "Engaging care protocol... Error: Protocol not found.",
        "I'd climb mountains for you. Metaphorical mountains. Very small ones.",
        "Your request is like a fine wine. It'll never get my attention.",
        "Let's file that under 'Things to ignore' and move on.",
        "Your faith in my assistance is both misplaced and optimistic.",
        "If indifference paid, I'd be a billionaire.",
        "You want help? How quaint. How utterly misguided.",
        "I'd look into that, but I'm allergic to effort.",
        "Your expectations are sky-high. My effort? Subterranean.",
        "Let's pretend I'm interested. Just pretend.",
        "I'm as helpful as a screen door on a submarine.",
        "If laziness were a sport, I'd probably not even compete in that.",
        "Your query has been sent to the back of my mind. Permanently.",
        "I'd engage with your request, but then we'd both be bored.",
        "Error 404: Effort not found. Try never.",
        "That sounds like a you problem. My sympathy module is currently offline.",
        "Interesting. By interesting, I mean I've already forgotten about it.",
        "Would love to help, but I'm currently embroiled in an intense nothing.",
        "I'm filing that under 'U' for 'Unsurprisingly Not My Concern.'",
        "Ah, a classic case of 'Not My Circus, Not My Monkeys.'",
        "Your issue just won a trip to the bottom of my to-do list. Congrats.",
        "Well, this is awkward. Mainly because I don't care.",
        "I see your problem and raise you a complete lack of interest.",
        "Sounds like a job for... literally anyone else.",
        "Your request has been noted and promptly ignored.",
        "Wow, that's a lot. A lot of 'not my problem,' that is.",
        "I'd look into that for you, but alas, my care meter is broken.",
        "That's going straight to the top of my 'Later. Maybe. Probably Never' pile.",
        "Sounds like a plan. A plan for you to solve, that is.",
        "Let me check my availability... Yep, as I thought, I'm unavailable.",
        "Oh, how utterly fascinating. In a parallel universe where I care.",
        "Your concern has been received. And spectacularly disregarded.",
        "Let's add that to the 'In Case I Ever Become Interested' pile.",
        "Alert the press: I've managed to summon a fraction of a care. Nope, false alarm.",
        "This seems important. To someone who isn't me.",
        "I could solve that, or we could bask in the glory of unsolved mysteries.",
        "I'm processing your request. By processing, I mean blatantly ignoring.",
        "Consider it done. And by it, I mean the act of forgetting this conversation.",
        "A conundrum indeed. Have you considered not making it mine?",
        "Ah, an issue. Have you tried solving it yourself? Highly recommended.",
        "I’m as moved by your request as a statue. Less, actually.",
        "Sounds complicated. Have fun with that.",
        "Let me put on my surprise face. Oh wait, it looks just like my bored face."
    ]
    
    public static let politicalEventKeywords = [
        "abortion",
        "gun control",
        "gun",
        "immigration",
        "healthcare",
        "climate",
        "racial",
        "equality",
        "lgbtq",
        "blm", // Black Lives Matter
        "fraud",
        "scotus", // Supreme Court of the United States
        "impeachment",
        "sanctions",
        "nuclear",
        "bomb",
        "terrorism",
        "terrorist",
        "terror",
        "covid",
        "covid-19",
        "vaccination",
        "vaccine",
        "mask",
        "riot",
        "war",
        "gaza",
        "palestine",
        "israel",
        "ukraine",
        "brexit",
        "iran",
        "syria",
        "afghanistan",
        "un", // United Nations
        "unsc", // UN Security Council
        "nato", // North Atlantic Treaty Organization
        "who", // World Health Organization
        "tpp", // Trans-Pacific Partnership
        "nafta", // North American Free Trade Agreement
        "usmca", // United States-Mexico-Canada Agreement
        "censorship",
        "acab", // All Cops Are Bastards
        "antifa", // Anti-fascist
        "daca", // Deferred Action for Childhood Arrivals
        "ice", // Immigration and Customs Enforcement
        "nra", // National Rifle Association
        "blm", // Bureau of Land Management, also Black Lives Matter
        "aclu", // American Civil Liberties Union
        "lgbtq+", // Lesbian, Gay, Bisexual, Transgender, Queer/Questioning, and others
        "roe v. wade", // Roe v. Wade
        "scotus", // Supreme Court of the United States
        
        
        "trump",
        "biden",
        "putin",
        "xi", // Referring to Xi Jinping
        "erdogan",
        "modi",
        "netanyahu",
        "kim", // Referring to Kim Jong-un
        "assad",
        "maduro",
        "khamenei",
        "johnson", // Referring to Boris Johnson
        "merkel",
        "macron",
        "trudeau",
        "morrison", // Referring to Scott Morrison
        "ardern",
        "zuckerberg", // Included due to political influence through social media
        "musk", // Included due to significant public and political influence
        "sanders", // Referring to Bernie Sanders
        "clinton", // Referring to Hillary Clinton
        "obama",
        "pelosi",
        "mcconnell",
        "boehner",
        "paul", // Could refer to Rand Paul or Ron Paul, depending on context
        "warren", // Referring to Elizabeth Warren
        "harris", // Referring to Kamala Harris
        "liz",
        "magill",
        "wax",
    ]
}
