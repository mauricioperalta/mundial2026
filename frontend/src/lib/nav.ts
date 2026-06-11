import { House, Volleyball, Telescope, Network, Trophy, LifeBuoy } from '@lucide/svelte';
import type { Component } from 'svelte';

export interface NavItem {
	href: string;
	label: string;
	icon: Component;
}

export const navItems: NavItem[] = [
	{ href: '/', label: 'Inicio', icon: House },
	{ href: '/tips', label: 'Pronósticos', icon: Volleyball },
	{ href: '/forecast', label: 'Predicción', icon: Telescope },
	{ href: '/tournament', label: 'El Torneo', icon: Network },
	{ href: '/leagues/xqrbkeemb72nagv', label: 'Resultados', icon: Trophy },
	{ href: '/ayuda', label: 'Ayuda', icon: LifeBuoy }
];

export function isActive(href: string, path: string): boolean {
	return href === '/' ? path === '/' : path.startsWith(href);
}
