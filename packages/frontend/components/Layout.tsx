import React from 'react';
import { WalletConnect } from './WalletConnect';

export const Layout = ({ children }: { children: React.ReactNode }) => {
    return (
        <div className="min-h-screen flex flex-col bg-gray-950 text-white">
            <header className="border-b border-gray-800 backdrop-blur-md sticky top-0 z-50 bg-gray-950/80">
                <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center font-bold text-lg">A</div>
                        <span className="font-bold text-xl tracking-tight">ArcShield</span>
                    </div>
                    <WalletConnect />
                </div>
            </header>

            <main className="flex-grow">
                {children}
            </main>

            <footer className="border-t border-gray-900 py-10 bg-gray-950">
                <div className="max-w-7xl mx-auto px-6 text-center text-gray-500 text-sm">
                    <p>© 2025 ArcShield Privacy DApp. Built on Arc Network.</p>
                    <div className="flex justify-center gap-6 mt-4">
                        <a href="#" className="hover:text-blue-400 transition-colors">Documentation</a>
                        <a href="#" className="hover:text-blue-400 transition-colors">GitHub</a>
                        <a href="#" className="hover:text-blue-400 transition-colors">Discord</a>
                    </div>
                </div>
            </footer>
        </div>
    );
};
