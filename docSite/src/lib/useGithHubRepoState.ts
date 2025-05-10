import { useEffect, useState } from 'react';
import axios from 'axios';

const GITHUB_OWNER = 'Djsmk123';
const GITHUB_REPO = 'flutter_credential_manager_compose';
const CACHE_KEY = 'github_repo_stats';
const CACHE_TTL = 1000 * 60 * 30; // 30 minutes

type GitHubStats = {
  stars: number;
  forks: number;
  lastCommitDate: string;
  totalCommits: number;
};

export const useGitHubRepoStats = () => {
  const [stats, setStats] = useState<GitHubStats | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Check cache
        const cached = localStorage.getItem(CACHE_KEY);
        if (cached) {
          const { data, timestamp } = JSON.parse(cached);
          if (Date.now() - timestamp < CACHE_TTL) {
            setStats(data);
            return;
          }
        }

        // Fetch fresh data
        const [repoRes, commitsRes] = await Promise.all([
          axios.get(`https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}`),
          axios.get(`https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/commits`),
        ]);

        const stars = repoRes.data.stargazers_count;
        const forks = repoRes.data.forks_count;
        const lastCommitDate = commitsRes.data[0].commit.committer.date;
        const totalCommits = repoRes.data.network_count || commitsRes.data.length;

        const freshData = { stars, forks, lastCommitDate, totalCommits };

        // Cache it
        localStorage.setItem(CACHE_KEY, JSON.stringify({ data: freshData, timestamp: Date.now() }));

        setStats(freshData);
      } catch (error) {
        console.error('Failed to fetch GitHub stats', error);
      }
    };

    fetchStats();
  }, []);

  return stats;
};
