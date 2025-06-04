export interface Session {
    id: number
    title: string
    scheduled_at: string
    summary?: string
    participants?: Array<{
        id: number
        name: string
    }>
} 