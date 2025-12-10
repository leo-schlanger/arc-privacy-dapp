"use client";

import { PrivacyForm } from "../components/PrivacyForm";

export default function Home() {
    return (
        <div className="flex flex-col items-center">
            {/* Hero Section */}
            <section className="w-full pt-24 pb-16 px-6 relative overflow-hidden">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-blue-600/10 rounded-full blur-3xl -z-10" />
                <div className="max-w-4xl mx-auto text-center space-y-6">
                    <h1 className="text-5xl md:text-7xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-400 tracking-tight">
                        Privacy for the <br />
                        <span className="text-blue-500">programmable money</span>
                    </h1>
                    <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                        Send USDC confidentially on Arc Network. Leverage native ZK-proofs for fast, compliant, and private transactions.
                    </p>
                </div>
            </section>

            {/* App Section */}
            <section className="w-full px-6 pb-24">
                <div className="max-w-md mx-auto relative">
                    <div className="absolute -inset-1 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-2xl blur opacity-25" />
                    <PrivacyForm />
                </div>
            </section>

            {/* Why Arc Section */}
            <section className="w-full bg-gray-900/30 border-y border-gray-900 py-24 px-6">
                <div className="max-w-6xl mx-auto">
                    <h2 className="text-3xl font-bold text-center mb-16">Why ArcShield?</h2>

                    <div className="grid md:grid-cols-3 gap-8">
                        <div className="p-8 rounded-2xl bg-gray-950 border border-gray-800 hover:border-blue-500/30 transition-colors">
                            <div className="w-12 h-12 rounded-lg bg-blue-900/20 flex items-center justify-center text-2xl mb-6">🔒</div>
                            <h3 className="text-xl font-bold mb-3">Native Privacy</h3>
                            <p className="text-gray-400">Built on Arc's "Opt-in Privacy" architecture using precompiled ZK verification.</p>
                        </div>

                        <div className="p-8 rounded-2xl bg-gray-950 border border-gray-800 hover:border-purple-500/30 transition-colors">
                            <div className="w-12 h-12 rounded-lg bg-purple-900/20 flex items-center justify-center text-2xl mb-6">⚡</div>
                            <h3 className="text-xl font-bold mb-3">Instant Finality</h3>
                            <p className="text-gray-400">Experience sub-second transaction confirmation times (~500ms deterministic).</p>
                        </div>

                        <div className="p-8 rounded-2xl bg-gray-950 border border-gray-800 hover:border-green-500/30 transition-colors">
                            <div className="w-12 h-12 rounded-lg bg-green-900/20 flex items-center justify-center text-2xl mb-6">🛡️</div>
                            <h3 className="text-xl font-bold mb-3">Audit Ready</h3>
                            <p className="text-gray-400">Stateless smart contract architecture designed for security and simplicity.</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    );
}
