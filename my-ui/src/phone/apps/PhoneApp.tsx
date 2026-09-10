import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  Camera, Check, ChevronRight, ChevronLeft, Clock3, ContactRound, Delete, Info, Images, Grid3X3, Mail, MessageCircle, MicOff, MoreHorizontal, Phone, PhoneIncoming, PhoneOff, PhoneOutgoing, Plus, Search, Smartphone, Star, UserRound, Video, Volume2, X
} from 'lucide-react';
import './PhoneApp.css';
import { nerve } from '@nerve/core';

// Mock Nerve service bindings
interface PhoneService {
  getContacts: () => Promise<any[]>;
  getRecents: () => Promise<any[]>;
  dial: (number: string) => Promise<any>;
  answer: () => Promise<any>;
  hangup: () => Promise<any>;
  setSpeaker: (enabled: boolean) => Promise<any>;
  setMuted: (enabled: boolean) => Promise<any>;
}

const contactAlphabet = [...'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '#'];
const keypadKeys = [
  { digit: '1', letters: '' },
  { digit: '2', letters: 'ABC' },
  { digit: '3', letters: 'DEF' },
  { digit: '4', letters: 'GHI' },
  { digit: '5', letters: 'JKL' },
  { digit: '6', letters: 'MNO' },
  { digit: '7', letters: 'PQRS' },
  { digit: '8', letters: 'TUV' },
  { digit: '9', letters: 'WXYZ' },
  { digit: '*', letters: '' },
  { digit: '0', letters: '+' },
  { digit: '#', letters: '' },
];
const tabs = [
  { id: 'recents', icon: Clock3, label: 'Recents' },
  { id: 'contacts', icon: ContactRound, label: 'Contacts' },
  { id: 'keypad', icon: Phone, label: 'Keypad' },
];

export const PhoneApp: React.FC = () => {
  const phoneService = nerve.GetService<PhoneService>('PhoneService');
  const [tab, setTab] = useState<'recents' | 'contacts' | 'keypad'>('recents');
  const [keypad, setKeypad] = useState<string>('');
  const [contacts, setContacts] = useState<any[]>([]);
  const [recents, setRecents] = useState<any[]>([]);
  const [activeCall, setActiveCall] = useState<any>(null);
  const [query, setQuery] = useState('');
  const [recentFilter, setRecentFilter] = useState<'all' | 'missed'>('all');
  const [recentQuery, setRecentQuery] = useState('');
  const [selectedNumber, setSelectedNumber] = useState('');

  // Fetch initial data
  useEffect(() => {
    phoneService?.getContacts().then(c => setContacts(c || []));
    phoneService?.getRecents().then(r => setRecents(r || []));
  }, [phoneService]);

  const visibleContacts = useMemo(() => {
    const needle = query.trim().toLowerCase();
    if (!needle) return contacts;
    return contacts.filter(
      (c) => c.name.toLowerCase().includes(needle) || c.phone_number.includes(needle.replace(/\D/g, ''))
    );
  }, [contacts, query]);

  const keypadSuggestions = useMemo(() => {
    const enteredDigits = keypad.replace(/\D/g, '');
    if (enteredDigits.length < 2 || /[*#]/.test(keypad)) return [];
    return contacts.filter(c => c.phone_number.replace(/\D/g, '').startsWith(enteredDigits));
  }, [keypad, contacts]);

  const addDigit = useCallback((digit: string) => {
    if (keypad.length < 10) setKeypad(prev => prev + digit);
  }, [keypad]);

  const handleDial = async (number: string) => {
    if (!number) return;
    try {
      const res = await phoneService?.dial(number);
      if (res?.success) {
         setActiveCall({ state: 'calling', otherNumber: number });
      }
    } catch(e) {}
  };

  const getContactName = (num: string) => {
     const c = contacts.find(c => c.phone_number === num);
     return c ? c.name : num;
  };

  const formatPhoneNumber = (num: string) => num; // Mock format

  return (
    <div className="phone-calls-app native-app phone-app--light">
      {activeCall ? (
        <section className="phone-active-call">
          <header className="phone-active-call__identity">
            <div className="phone-active-call__status">Calling</div>
            <h1>{getContactName(activeCall.otherNumber)}</h1>
          </header>
          <div className="phone-active-call__actions">
             <button className="phone-call-action phone-call-action--end" onClick={() => { phoneService?.hangup(); setActiveCall(null); }}>
               <PhoneOff size={32} />
               <span>End</span>
             </button>
          </div>
        </section>
      ) : (
        <div className="phone-call-content">
          {tab === 'keypad' && (
            <section className="phone-keypad">
              {keypadSuggestions.length > 0 && (
                <div className="phone-keypad-suggestions" aria-live="polite">
                  {keypadSuggestions.map(contact => (
                    <button key={contact.id} className="phone-keypad-suggestion" onClick={() => setKeypad(contact.phone_number)}>
                       <span className="phone-keypad-suggestion__avatar">
                         {contact.avatar_url ? <img src={contact.avatar_url} alt="" /> : <span>{contact.name.charAt(0)}</span>}
                       </span>
                       <span className="phone-keypad-suggestion__copy">
                         <strong>{contact.name}</strong>
                         <small>{formatPhoneNumber(contact.phone_number)}</small>
                       </span>
                    </button>
                  ))}
                </div>
              )}
              <div className="phone-keypad-number" aria-live="polite">
                {/[*#]/.test(keypad) ? keypad : formatPhoneNumber(keypad)}
              </div>
              <div className="phone-keypad-grid">
                {keypadKeys.map(key => (
                  <button key={key.digit} className="phone-keypad-key" onClick={() => addDigit(key.digit)}>
                    <span>{key.digit}</span>
                    <small className={key.digit === '0' ? 'phone-keypad-plus' : ''}>{key.letters}</small>
                  </button>
                ))}
              </div>
              <div className="phone-keypad-actions">
                <button className="phone-keypad-call" onClick={() => handleDial(keypad)}>
                  <Phone size={31} fill="currentColor" />
                </button>
                {keypad && (
                  <button className="phone-keypad-delete" onClick={() => setKeypad(keypad.slice(0, -1))}>
                    <Delete size={27} />
                  </button>
                )}
              </div>
            </section>
          )}

          {tab === 'contacts' && (
            <section className="phone-contacts">
               <header className="phone-contacts-header">
                 <div className="phone-contacts-toolbar">
                   <h1 className="col-start-2 text-center text-[17px]">Contacts</h1>
                   <button className="phone-contacts-add col-start-3 ml-auto">
                     <Plus />
                   </button>
                 </div>
                 <div className="phone-contacts-search">
                   <Search size={21} />
                   <input type="search" placeholder="Search" value={query} onChange={e => setQuery(e.target.value)} />
                 </div>
               </header>
               <div className="phone-contact-group">
                 {visibleContacts.map(contact => (
                    <button key={contact.id} className="phone-contact-row" onClick={() => setSelectedNumber(contact.phone_number)}>
                       <div className="phone-contact-avatar">
                         {contact.avatar_url ? <img src={contact.avatar_url} alt="" /> : contact.name.charAt(0)}
                       </div>
                       <div className="phone-contact-name">
                         {contact.name}
                       </div>
                    </button>
                 ))}
               </div>
            </section>
          )}

          {tab === 'recents' && (
            <section className="phone-recents">
               <header className="phone-recents-header">
                 <h1>Recents</h1>
                 <div className="phone-recents-search">
                   <Search size={21} />
                   <input type="search" placeholder="Search" value={recentQuery} onChange={e => setRecentQuery(e.target.value)} />
                 </div>
               </header>
               <div className="phone-recents-list">
                 {recents.map(recent => (
                    <div key={recent.id} className="phone-recent-row">
                      <div className="phone-contact-avatar">
                         {getContactName(recent.other_number).charAt(0)}
                      </div>
                      <button className="phone-recent-call" onClick={() => handleDial(recent.other_number)}>
                        <span className="phone-recent-name">{getContactName(recent.other_number)}</span>
                        <span className="phone-recent-meta">
                          {recent.direction === 'incoming' ? <PhoneIncoming size={14}/> : <PhoneOutgoing size={14}/>}
                          {recent.status}
                        </span>
                      </button>
                    </div>
                 ))}
               </div>
            </section>
          )}

        </div>
      )}

      {!activeCall && (
        <nav className="phone-bottom-tabbar flex w-full justify-around p-2 bg-transparent absolute bottom-0 z-10">
          {tabs.map(item => {
             const Icon = item.icon;
             return (
               <button key={item.id} className="flex flex-col items-center" onClick={() => setTab(item.id as any)}>
                 <Icon size={24} />
                 <span className="text-xs">{item.label}</span>
               </button>
             );
          })}
        </nav>
      )}
    </div>
  );
};

export default PhoneApp;
